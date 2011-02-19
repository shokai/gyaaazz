#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

before do
  @title = 'gyaaazz'
end

get '/' do
  haml :index
end

get '/*.json' do
  name = params[:splat].first
  begin
    status 200
    page = Page.where(:name => name).first
    @mes = page.to_hash.to_json
  rescue
    status 404
    @mes = {:error => 'page not found'}.to_json
  end
end

post '/*.json' do
  name = params[:splat].first
  lines = params[:lines].delete_if{|i| i.size < 1 or i =~ /^\s+$/}
  now = Time.now
  begin
    page = Page.where(:name => name).first
    page.lines = lines
    page.time = now
    page.save
    @mes = {:success => true, :message => 'saved!'}.to_json
  rescue => e
    STDERR.puts e
    @mes = {:error => true, :message => 'save error!'}.to_json
  end
end

get '/*/' do
  
end

get '/*' do
  @name = params[:splat].first
  haml :edit
end
