#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

before do
  @title = 'gyaaazz'
end

def filter_api
  if env['PATH_INFO'] =~ /^\/api[\/$]/
    redirect "#{app_root}#{env['PATH_INFO'].gsub(/api/,'API')}"
  end
end

get '/api/search.json' do
  word = params['word']
  if !word or word.size < 1
    @mes = {:error => true, :message => 'word required'}.to_json
  else
    @pages = Page.where(:lines => /#{word}/).desc(:time)
    @mes = @pages.map{|i|
      h = {
        :name => i.name,
        :lines => i.lines.size,
        :time => i.time
      }
      for line in i.lines do
        if line =~ /\[\[(https?\:[\w\.\~\-\/\?\&\+\=\:\@\%\;\#\%]+)(.jpe?g|.gif|.png)\]\]/
          h[:img] = line.scan(/\[\[(https?\:[\w\.\~\-\/\?\&\+\=\:\@\%\;\#\%]+)(.jpe?g|.gif|.png)\]\]/).first.join('')
          break
        end
      end
      h
    }.to_json
  end
end

get '/api/related_pages.json' do
  name = params['page']
  if !name or name.size < 1
    @mes = {:error => true, :message => 'page required'}.to_json
  else
    @pages = Array.new
    begin
      Page.where(:lines => /\[\[#{name}\]\]/).each{|page|
        @pages << page
        Page.where(:lines => /\[\[#{page.name}\]\]/).each{|i|
          @pages << i
        }
      }
      @pages = @pages.uniq.delete_if{|i|
        i.name == name
      }.sort{|a,b|
        b.time <=> a.time
      }.map{|i|
        h = {
          :name => i.name,
          :lines => i.lines.size,
          :time => i.time
        }
        for line in i.lines do
          if line =~ /\[\[(https?\:[\w\.\~\-\/\?\&\+\=\:\@\%\;\#\%]+)(.jpe?g|.gif|.png)\]\]/
            h[:img] = line.scan(/\[\[(https?\:[\w\.\~\-\/\?\&\+\=\:\@\%\;\#\%]+)(.jpe?g|.gif|.png)\]\]/).first.join('')
            break
          end
        end
        h
      }
      @mes = @pages.to_json
    rescue => e
      STDERR.puts e
      @mes = {:error => true, :message => 'error'}.to_json
    end
  end
end

get '/' do
  @pages = Page.all.desc(:time).map{|i| i.name}.uniq
  haml :index
end

get '/*/' do
  filter_api
  name = params[:splat].first
  @pages = Page.where(:name => /#{name}\//).map{|i| i.name}.uniq
  haml :index
end

get '/*.json' do
  filter_api
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
  filter_api
  name = params[:splat].first
  lines = params[:lines].delete_if{|i| i.size < 1 or i =~ /^\s+$/}
  now = Time.now
  page = Page.where(:name => name).desc(:time).first
  if page and page.lines == lines
    @mes = {:success => true, :message => 'save'}.to_json
  else
    begin
      page = Page.new unless page
      page.name = name
      page.lines = lines
      page.time = now
      page.save
      PageLog.new(:name => name, :lines => lines, :time => now).save
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
  filter_api
  @name = params[:splat].first
  haml :edit
end
