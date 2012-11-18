require 'rubygems'
require 'bundler'

Bundler.require

`require File.dirname(__FILE__) + '/uuidwaster.rb'`
run Sinatra::Application