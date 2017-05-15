#!/usr/bin/env ruby"
# -*- coding: utf-8 -*-

require "#{File.dirname(__FILE__)}/SwiftPoetryProject"
require "test/unit"
require 'nokogiri'

class TeiDocumentSetTest < Test::Unit::TestCase

  #FILE_PATHS = [ 'master/001A/366-001A', 'master/001A/811-001A' ]
  FILE_PATHS = [ 'master/001A/366-001A', 'master/001B/156-001B', 'master/001B/274-001B' ]

  def setup
    
    @docs = FILE_PATHS.map do |filePath|
      
      SwiftPoetryProject::TeiParser.new(filePath).parse
    end

    @set = SwiftPoetryProject::TeiDocumentSet.new(@docs)
  end

  def testConcatenate
    
    @set.concatenate()
  end

  def testIntegrate

    @set.integrate().to_xml
  end

  def testOrderedIntegrate

    @set.orderedIntegrate().to_xml
  end

  def testDeeplyIntegrate

    puts @set.deeplyIntegrate().to_xml
    # @set.deeplyIntegrate()
  end
end
