# coding: utf-8
require_relative '../../app'
require_relative '../test_helper'
require 'test/unit'
require 'rack/test'

class PoemsTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    SwiftPoemsProject::App.new
  end

  def test_poem
    get '/poems/686-'
    
    assert last_response.ok?
    assert_equal 'application/json', last_response.content_type
    poems = JSON.parse(last_response.body)
    assert poems.is_a? Array
  end

  def test_index
    get '/poems/'

    assert last_response.ok?
    assert_equal 'application/json', last_response.content_type
    poems = JSON.parse(last_response.body)
    assert poems.is_a? Array
  end
end
