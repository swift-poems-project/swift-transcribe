#!/usr/bin/env ruby"
# -*- coding: utf-8 -*-

require "#{File.dirname(__FILE__)}/SwiftPoetryProject"
require "test/unit"
require 'nokogiri'

class NotaBeneHeadnoteParserTest < Test::Unit::TestCase

  def setup

    @document = Nokogiri::XML(<<EOF
<TEI version="5.0" xmlns="http://www.tei-c.org/ns/1.0">
  <teiHeader>
    <fileDesc>
      <titleStmt>
	<title>The shortest TEI Document Imaginable</title>
      </titleStmt>
      <publicationStmt>
	<p>First published as part of TEI P2, this is the P5
          version using a name space.</p>
      </publicationStmt>
      <sourceDesc>
	<p>No source: this is an original work.</p>
      </sourceDesc>
    </fileDesc>
  </teiHeader>
  <text>
    <body>
      <p>This is about the shortest TEI document imaginable.</p>
    </body>
  </text>
</TEI>
EOF
)

=begin
    @lines = <<EOF

EOF
=end

    @case1 = "193-003K   HN1 Written in the Year 1713."
    @case2 = "193-003K   HN2 «MDUL»A few of the first Lines were wanting in the Copy sent us by a Friend of the Author's from «MDNM»London."
    @case3 = "193-003K   HN3 «MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*_«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*"
=begin
    @teiParser = SwiftPoetryProject::TeiParser.new(nil, :lines => @lines)
    @teiParser.parseHeader

    @parser = SwiftPoetryProject::NotaBeneHeadnoteParser.new(@teiParser, @lines)
=end
  end

  def testParse

    # Case 1
    @teiParser = SwiftPoetryProject::TeiParser.new(nil, :lines => @case1)
    @teiParser.parseHeader
    @parser = SwiftPoetryProject::NotaBeneHeadnoteParser.new(@teiParser, @case1)

    assert_equal '<head n="1">Written in the Year 1713.</head>', @parser.parse.to_xml

    # Case 2
    @teiParser = SwiftPoetryProject::TeiParser.new(nil, :lines => @case2)
    @teiParser.parseHeader
    @parser = SwiftPoetryProject::NotaBeneHeadnoteParser.new(@teiParser, @case2)

    assert_equal '<head n="2"><hi rend="underline">A few of the first Lines were wanting in the Copy sent us by a Friend of the Author\'s from </hi>London.</head>', @parser.parse.to_xml

    # Case 3
    @teiParser = SwiftPoetryProject::TeiParser.new(nil, :lines => @case3)
    @teiParser.parseHeader
    @parser = SwiftPoetryProject::NotaBeneHeadnoteParser.new(@teiParser, @case3)
    @parser.parse

    assert_equal '<head n="3"><unclear reason="illegible"/></head>', @parser.parse.to_xml
  end
end
