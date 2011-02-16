#!/usr/bin/env ruby
# -*- coding: utf-8 -*-


get '/' do
  @title = 'gyaaazz'
  haml :index
end
