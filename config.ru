require "rubygems"
require "sinatra"

Bundler.require

require File.expand_path('../app', __FILE__)
require 'sidekiq/web'

run Rack::URLMap.new('/' => Sinatra::Application, '/sidekiq' => Sidekiq::Web)
