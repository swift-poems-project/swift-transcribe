Bundler.require

require "rubygems"
require 'sidekiq/web'
require "sinatra"
require File.expand_path('../app', __FILE__)

run Rack::URLMap.new('/' => SwiftPoemsProject::App, '/sidekiq' => Sidekiq::Web)
