# -*- coding: utf-8 -*-
require 'date'
require 'fileutils'
require 'google/apis/drive_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'logger'
require 'open-uri'
require 'parseconfig'
require 'redis'
require 'sidekiq'
require 'sidekiq/api'
require 'sinatra'
require 'sinatra/cross_origin'
require 'tilt/haml'

require 'swift_encode'
require_relative 'app/lib/configuration'
require_relative 'app/routes'

module SwiftPoemsProject
  class App < Sinatra::Application
    extend Configuration
    configure_app

    before do
      env["rack.errors"] =  $error_logger
    end

    use Routes::Transcripts
    use Routes::Poems
    use Routes::Home
  end
end
