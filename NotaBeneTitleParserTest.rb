#!/usr/bin/env ruby"
# -*- coding: utf-8 -*-

require "#{File.dirname(__FILE__)}/SwiftPoetryProject"
require "test/unit"
require 'nokogiri'

class NotaBeneTitleParserTest < Test::Unit::TestCase

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

    @lines = <<EOF
193-003K   THE | A«MDSD»UTHOR«MDNM» upon Himself.
EOF

    @case2 = "811-001A   On the Words «MDUL»Brother-Protestants«MDNM», and | «MDUL»Fellow-Christians«MDNM», so familiarly used | by the advocates for the repeal of the «MDBU»Test- | Act«MDNM» in Ireland. «FN1·This poem so provok'd one Bettesworth a Lawyer, and member of the Irish parliament, that he swore he would revenge himself, either by murdering or maiming the Author. on this, Thirty of the Nobility and Gentry of the Liberty of St Patrick's, waited on the Dean, With a paper, subscrib'd by them, in which they engaged, to defend his person, and fortune, as the friend, and Benefactor of his Country.»"

    @teiParser = SwiftPoetryProject::TeiParser.new(nil, :lines => @lines)
    @teiParser.parseHeader

    @parser = SwiftPoetryProject::NotaBeneTitleParser.new(@teiParser, @lines)

  end

  def testParse

    # Case 1: "193-003K   THE | A«MDSD»UTHOR«MDNM» upon Himself."
    # assert_equal '<title>THE<lb/>A<hi rend="SMALL-CAPS">UTHOR</hi> upon Himself.</title>', @parser.parse.to_xml

    @teiParser = SwiftPoetryProject::TeiParser.new(nil, :lines => @case2)
    @teiParser.parseHeader
    @parser = SwiftPoetryProject::NotaBeneTitleParser.new(@teiParser, @case2)

    assert_equal '<title>On the Words <hi rend="underline">Brother-Protestants</hi>, and<lb/><hi rend="underline">Fellow-Christians</hi>, so familiarly used<lb/>by the advocates for the repeal of the Test-<lb/><hi rend="special-state">Act</hi> in Ireland. <note place="foot">This poem so provok\'d one Bettesworth a Lawyer, and member of the Irish parliament, that he swore he would revenge himself, either by murdering or maiming the Author. on this, Thirty of the Nobility and Gentry of the Liberty of St Patrick\'s, waited on the Dean, With a paper, subscrib\'d by them, in which they engaged, to defend his person, and fortune, as the friend, and Benefactor of his Country.</note></title>', @parser.parse.to_xml

  end  
end
