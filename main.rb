#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

before do
  @title = 'gyaaazz'
end

get '/' do
  @pages = Page.all.desc(:time).map{|i| i.name}.uniq
  haml :index
end

get '/*/' do
  name = params[:splat].first
  @pages = Page.where(:name => /#{name}\//).map{|i| i.name}.uniq
  haml :index
end

get '/*.json' do
  name = params[:splat].first
  begin
    status 200
    page = Page.where(:name => name).desc(:time).first
    unless page
      page = Page.new
      page.time = Time.now
      page.name = name
      page.save
    end
    @mes = page.to_hash.to_json
  rescue => e
    STDERR.puts e
    status 404
    @mes = {:error => 'page not found'}.to_json
  end
end

post '/*.json' do
  name = params[:splat].first
  lines = params[:lines].delete_if{|i| i.size < 1 or i =~ /^\s+$/}
  now = Time.now
  last_page = Page.where(:name => name).desc(:time).first
  if last_page and last_page.lines == lines
    @mes = {:success => true, :message => 'save'}.to_json
  else
    begin
      page = Page.new(:name => name, :lines => lines, :time => now)
      page.save
      @mes = {:success => true, :message => 'saved!'}.to_json
    rescue => e
      STDERR.puts e
      @mes = {:error => true, :message => 'save error!'}.to_json
    end
  end
end

get '/*/' do
  
end

get '/*' do
  @name = params[:splat].first
  haml :edit
end
