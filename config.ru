require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'sinatra'
require 'logger'
$logger = Logger.new $stdout
if development?
  $stdout.sync = true
  $logger.level = Logger::INFO
  require 'sinatra/reloader'
elsif production?
  $logger.level = Logger::WARN
end
require 'sinatra/content_for'
require 'haml'
require 'json'
$:.unshift File.dirname(__FILE__)
require 'inits/db'
require 'models/page'
require 'models/pagelog'
require 'helpers/helper'
require 'controllers/main'

set :haml, :escape_html => true

run Sinatra::Application
