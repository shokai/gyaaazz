#!/usr/bin/env ruby
# -*- coding: utf-8 -*-


get '/' do
  @title = 'gyaaazz'
  haml :index
end

get '/*.json' do
  name = params[:splat].first
  begin
    status 200
    @mes = Page.where(:name => name).first.to_hash.to_json
  rescue
    status 404
    @mes = {:error => 'page not found'}.to_json
  end
end

post '/*.json' do
  name = params[:splat].first
  body = params['body']
  if body == nil or body.size < 1
    status 400
    @mes = {:error => 'parameter "body" required'}.to_json
  end
  page = Page.where(:name => name).first
  unless page
    page = Page.new(:name => name, :body => body, :time => Time.now.to_i)
  else
    page.body = body
    page.time = Time.now.to_i
  end
  begin
    page.save
    @mes = page.to_hash.to_json
  rescue
    status 500
    @mes = {:error => 'page save error'}.to_json
  end
  
end

get '/*/' do
  
end

get '/*' do
  name = params[:splat].first
  puts name
end
