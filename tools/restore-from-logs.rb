#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'bson'
gem 'mongoid','>=2.0.0.rc.7'
require 'mongoid'
require File.dirname(__FILE__)+'/../models/page'
require File.dirname(__FILE__)+'/../models/pagelog'
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
  puts 'pagename required'
  puts 'e.g. ruby restore-from-logs.rb "pagename"'
  exit 1
end
name = ARGV.shift
if name =~ /^\/.+\/$/
  reg = name.scan(/\/(.+)\//).first.first
  name = /#{reg}/
end

puts "restore #{name}"

Mongoid.configure{|conf|
  conf.master = Mongo::Connection.new(@@conf['mongo_server'], @@conf['mongo_port']).db(@@conf['mongo_dbname'])
}


restored = Array.new
PageLog.where(:name => name).desc(:time).each{|log|
  next if restored.include?(log.name)
  p log
  begin
    Page.new(log.to_hash).save
    restored << log.name
  rescue => e
    STDERR.puts 'restore error!'
    STDERR.puts e
  end
}
