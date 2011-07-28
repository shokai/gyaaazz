#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
before do
  @title = 'gyaaazz'
end

post '/api/copy.json' do
  from = params['from']
  to = params['to']
  if from.to_s.size < 1 or to.to_s.size < 1
    @mes = {:error => true, :message => 'from and to required'}.to_json
  else
    begin
      page_from = Page.where(:name => from).first
      if Page.where(:name => to).count < 1
        page_to = Page.new(page_from.to_hash)
        page_to.name = to
        page_to.save
        @mes = {:from => from, :to => to, :method => 'copy'}.to_json
      else
        @mes = {:error => true, :message => 'page already exists'}.to_json
      end
    rescue => e
      STDERR.puts e
      @mes = {:error => true, :message => 'copy error'}.to_json
    end
  end
end

post '/api/rename.json' do
  from = params['from']
  to = params['to']
  if from.to_s.size < 1 or to.to_s.size < 1
    @mes = {:error => true, :message => 'from and to required'}.to_json
  else
    begin
      if Page.where(:name => to).count < 1
        page = Page.where(:name => from).first
        page.name = to
        page.save
        @mes = {:from => from, :to => to, :method => 'rename'}.to_json
      else
        @mes = {:error => true, :message => 'page already exists'}.to_json
      end
    rescue => e
      STDERR.puts e
      @mes = {:error => true, :message => 'rename error'}.to_json
    end
  end
end


get '/api/search.json' do
  word = params['word']
  if word.to_s.size < 1
    @pages = Page.all.desc(:time)
  else
    @pages = Page.where(:lines => /#{word}/).desc(:time)
  end
  @mes = @pages.map{|i|
    h = {
      :name => i.name,
      :time => i.time
    }
    if i.lines != nil and i.lines.class == Array
      h[:lines] = i.lines.size
    else
      h = nil
    end
    h
  }.delete_if{|i| i == nil}.to_json
end

get '/api/related_pages.json' do
  name = params['page']
  if !name or name.size < 1
    @mes = {:error => true, :message => 'page required'}.to_json
  else
    tmp = Hash.new
    begin
      Page.where(:lines => /\[\[#{name}\]\]/).each{|page|
        tmp[page.name] = page unless tmp[page.name]
        Page.where(:lines => /\[\[#{page.name}\]\]/).each{|i|
          tmp[i.name] = i unless tmp[i.name]
        }
      }
      pages = tmp.values.uniq.delete_if{|i|
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
      @mes = pages.to_json
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
    end
    @mes = page.to_hash.to_json
  rescue => e
    STDERR.puts e
    status 404
    @mes = {:error => true, :message => 'page not found'}.to_json
  end
end

post '/*.json' do
  filter_api
  name = params[:splat].first
  lines = params[:lines].delete_if{|i| i.size < 1 or i =~ /^\s+$/}
  if lines.size == 1 and lines.first == '(empty)'
    begin
      Page.where(:name => name).delete_all
      @mes = {:success => true, :message => 'delete!'}.to_json
    rescue => e
      STDERR.puts e
      @mes = {:error => true, :message => 'delete error'}.to_json
    end
  else
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
end

get '/*' do
  filter_api
  @name = params[:splat].first
  haml :page
end
