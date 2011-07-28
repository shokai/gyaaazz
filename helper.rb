require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'sinatra/reloader' if development?
require 'bson'
gem 'mongoid','>=2.0.0'
require 'mongoid'
require 'yaml'
require 'json'
require File.dirname(__FILE__)+'/models/page'
require File.dirname(__FILE__)+'/models/pagelog'

begin
  @@conf = YAML::load open(File.dirname(__FILE__)+'/config.yaml').read
  p @@conf
rescue => e
  STDERR.puts 'config.yaml load error!'
  STDERR.puts e
end

Mongoid.configure{|conf|
  conf.master = Mongo::Connection.new(@@conf['mongo_server'], @@conf['mongo_port']).db(@@conf['mongo_dbname'])
}

def app_root
  "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}#{env['SCRIPT_NAME']}"
end

def filter_api
  if env['PATH_INFO'] =~ /^\/api[\/$]/
    redirect "#{app_root}#{env['PATH_INFO'].gsub(/api/,'API')}"
  end
end
