# coding: utf-8
require_relative '../../app'
require_relative '../test_helper'
require 'test/unit'
require 'rack/test'

class TranscriptsTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    SwiftPoemsProject::App.new
  end
  
  def test_encode
    get '/transcripts/686-0201/encode'
    
    assert last_response.ok?
    assert_equal 'application/tei+xml', last_response.content_type
    tei_doc = Nokogiri::XML(last_response.body)

    header_elem = tei_doc.at_xpath('/tei:TEI/tei:teiHeader', 'tei' => 'http://www.tei-c.org/ns/1.0')
    assert header_elem
    text_elem = tei_doc.at_xpath('/tei:TEI/tei:text', 'tei' => 'http://www.tei-c.org/ns/1.0')
    assert text_elem
    body_elem = tei_doc.at_xpath('/tei:TEI/tei:text/tei:body', 'tei' => 'http://www.tei-c.org/ns/1.0')
    assert body_elem
  end

  def test_encode_with_source
    get '/transcripts/686-/686-0201/encode'

    assert last_response.ok?
    assert_equal 'application/tei+xml', last_response.content_type
    tei_doc = Nokogiri::XML(last_response.body)

    header_elem = tei_doc.at_xpath('/tei:TEI/tei:teiHeader', 'tei' => 'http://www.tei-c.org/ns/1.0')
    assert header_elem
    text_elem = tei_doc.at_xpath('/tei:TEI/tei:text', 'tei' => 'http://www.tei-c.org/ns/1.0')
    assert text_elem
    body_elem = tei_doc.at_xpath('/tei:TEI/tei:text/tei:body', 'tei' => 'http://www.tei-c.org/ns/1.0')
    assert body_elem
  end

  def test_encode_with_content

    transcript_file_path = File.join(File.dirname(File.expand_path(__FILE__)), '..', '..', 'tmp', 'nb', '686-0201')
    body = File.read(transcript_file_path)
    body = body.encode('utf-8','cp437')
    post '/transcripts/encode', :id => '686-0201', :transcript => body
    assert last_response.ok?
    assert_equal 'application/tei+xml', last_response.content_type

    tei_doc = Nokogiri::XML(last_response.body)

    header_elem = tei_doc.at_xpath('/tei:TEI/tei:teiHeader', 'tei' => 'http://www.tei-c.org/ns/1.0')
    assert header_elem
    text_elem = tei_doc.at_xpath('/tei:TEI/tei:text', 'tei' => 'http://www.tei-c.org/ns/1.0')
    assert text_elem
    body_elem = tei_doc.at_xpath('/tei:TEI/tei:text/tei:body', 'tei' => 'http://www.tei-c.org/ns/1.0')
    assert body_elem
  end
end
