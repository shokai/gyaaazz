#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'bson'
gem 'mongoid','>=2.0.0.rc.7'
require 'mongoid'
require File.dirname(__FILE__)+'/../models/page'
require 'open-uri'
require 'kconv'
require 'uri'
require 'nokogiri'
require 'yaml'
$KCODE = 'u'

begin
  @@conf = YAML::load open(File.dirname(__FILE__)+'/../config.yaml').read
  p @@conf
rescue => e
  STDERR.puts 'config.yaml load error!'
  STDERR.puts e
end

if ARGV.size < 1
  puts 'gyazzname required'
  puts 'e.g. ruby gyazz-import-gyaaazz.rb "gyazzname"'
  exit 1
end
name = ARGV.shift

Mongoid.configure{|conf|
  conf.master = Mongo::Connection.new(@@conf['mongo_server'], @@conf['mongo_port']).db(@@conf['mongo_dbname'])
}

def get_pagelist(name)
  doc = Nokogiri::HTML open(URI.encode "http://gyazz.com/#{name}/")
  urls = doc.xpath('//a').map{|a| a}.delete_if{|a|
    !(a['href'] =~ /http:\/\/gyazz.com\/#{name}\/(.+)/)
  }.map{|a|
    URI.decode a['href'].scan(/http:\/\/gyazz.com\/#{name}\/(.+)/).first.first
  }
end

def get_page(name, page_name)
  data = open(URI.encode "http://gyazz.com/#{name}/#{page_name}/text").read.toutf8
  lines = data.split(/[\r\n]/)
  lines
end

errors = Array.new
pages = get_pagelist(name)

for i in 0...pages.size do
  page = pages[i]
  begin
    puts "===#{page} (#{i}/#{pages.size})==="
    pagename = page.gsub(/\+/,' ')
    next if pagename =~ /\/$/
    next if Page.where(:name => pagename).count < 1
    puts lines = get_page(name, page)
    next if lines.size < 1
    Page.new(
             :name => pagename,
             :time => Time.now.to_i,
             :lines => lines
             ).save
  rescue => e
    STDERR.puts e
    errors << page
  ensure
    sleep 1
  end
end

if errors.size > 0
  puts 'error pages:'
  p errors
end
