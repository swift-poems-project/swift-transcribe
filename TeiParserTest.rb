#!/usr/bin/env ruby"
# -*- coding: utf-8 -*-

require "#{File.dirname(__FILE__)}/SwiftPoetryProject"
require "test/unit"
require 'nokogiri'

class TeiParserTest < Test::Unit::TestCase

  FILE_PATH = 'master/001A/366-001A'
  #FILE_PATH = '613-0653'

  def setup

    @parser = SwiftPoetryProject::TeiParser.new(FILE_PATH)



=begin
It is a long-standing requirement for any TEI Conformant document that it should contain a teiHeader element. To be more specific a TEI Conformant document must contain either:

    a single teiHeader element followed by a single text element, in that order; or
    in the case of a corpus or collection, a single overall teiHeader element followed by a series of TEI elements each with its own teiHeader

All teiHeader elements in a TEI Conformant document must include elements for:

Title Statement
    This should include the title of the TEI document expressed using a titleStmt element.
Publication Statement
    This should include the place and date of publication or distribution of the TEI document, expressed using the publicationStmt element.
Source Statement
    For a document derived from some previously existing document, this must include a bibliographic description of that source. For a document not so derived, this must include a brief statement that the document has no pre-existing source. In either case, this will be expressed using the sourceDesc element.
(http://www.tei-c.org/release/doc/tei-p5-doc/en/html/USE.html#CFAMmc)
=end

    # (http://www.tei-c.org/release/doc/tei-p5-doc/en/html/examples-TEI.html)

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

    # "The smallest possible valid TEI Header thus looks like this"
    # (http://www.tei-c.org/release/doc/tei-p5-doc/en/html/HD.html#HD11)
    @header = Nokogiri::XML(<<EOF
<teiHeader>
  <fileDesc>
    <titleStmt>
      <title>
	<!-- title of the resource -->
      </title>
    </titleStmt>
    <publicationStmt>
      <p>(Information about distribution of the
	resource)</p>
    </publicationStmt>
    <sourceDesc>
      <p>(Information about source from which the resource derives)</p>
    </sourceDesc>
  </fileDesc>
</teiHeader>
EOF
)
  end

  def testParseNotaBeneMElement

    testElement = Nokogiri::XML::Node.new('l', @parser.teiDocument)
    testElement.content = "«MDUL»alpha«MDNM»"

    result = @parser.parseNotaBeneToken('«MDUL»', '«MDNM»', testElement)
    
    assert_equal(result.content, 'alpha')
    assert_equal(result.to_xhtml, "<l>\n  <hi rend=\"underline\">alpha</hi>\n</l>")
    
    # Handling for <l>And thus I solve this hard «MDUL»Ph\ae\nomenon«MDNM».</l>
    testElement = Nokogiri::XML::Node.new('l', @parser.teiDocument)
    testElement.content = 'And thus I solve this hard «MDUL»Ph\ae\nomenon«MDNM».'
    
    result = @parser.parseNotaBeneToken('«MDUL»', '«MDNM»', testElement)
    
    assert_equal(result.to_s, '<l>And thus I solve this hard <hi rend="underline">Ph\ae\nomenon</hi>.</l>')
  end

   def testParseNotaBeneMarkup

=begin
     stanzaElement = Nokogiri::XML::Node.new('lg', @parser.teiDocument)
     @parser.teiDocument.at_xpath('tei:TEI/tei:text/tei:body/tei:div', SwiftPoetryProject::TeiParser::TEI_NS).add_child stanzaElement

     testElement = Nokogiri::XML::Node.new('l', @parser.teiDocument)
     testElement.content = '\\ae\\'

     assert_equal(@parser.parseNotaBeneMarkup(testElement, stanzaElement).content, 'æ')

     testElement = Nokogiri::XML::Node.new('l', @parser.teiDocument)
     testElement.content = '·'

     assert_equal(@parser.parseNotaBeneMarkup(testElement, stanzaElement).to_s, '<l>&#xA0;</l>')

     testElement = Nokogiri::XML::Node.new('l', @parser.teiDocument)
     testElement.content = '«MDUL»\\ae\\«MDNM»'

     result = @parser.parseNotaBeneMarkup(testElement, stanzaElement)
     
     assert_equal(result.content, 'æ')
     assert_equal(result.to_xhtml, "<l>\n  <hi rend=\"underline\">&#xE6;</hi>\n</l>")

     testElement = Nokogiri::XML::Node.new('l', @parser.teiDocument)
     testElement.content = 'beta 3}'

     result = @parser.parseNotaBeneMarkup(testElement, stanzaElement)

     assert_equal(result.content, 'beta')
     assert_equal(@parser.teiDocument.at_xpath('tei:TEI/tei:text/tei:body/tei:div/tei:lg/@type', SwiftPoetryProject::TeiParser::TEI_NS).content, 'triplet')

     testElement = Nokogiri::XML::Node.new('l', @parser.teiDocument)
     testElement.content = 'gamma «FC»delta«FL» epsilon'

     # SPP-10: Refactor with parseXMLTextNode
=end
=begin
     result = @parser.parseNotaBeneMarkup(testElement, stanzaElement)

     assert_equal(result.content, 'gamma epsilon')
     assert_equal(result.to_xhtml, '<l>gamma epsilon</l>')
     assert_equal(@parser.teiDocument.at_xpath('tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:head', SwiftPoetryProject::TeiParser::TEI_NS).to_s, '<head>delta</head>')
=end
=begin
     testElement = Nokogiri::XML::Node.new('l', @parser.teiDocument)
     testElement.content = 'zeta \\eta\\ theta'

     result = @parser.parseNotaBeneMarkup(testElement, stanzaElement)

     assert_equal(result.to_s, '<l>zeta <note>eta</note> eta</l>')

     testElement = Nokogiri::XML::Node.new('l', @parser.teiDocument)
     testElement.content = 'iota kap-|pa lambda'

     result = @parser.parseNotaBeneMarkup(testElement, stanzaElement)

     assert_equal(result.to_s, '<l>iota kappa <note>ambiguous hyphenation</note> lambda</l>')

     testElement = Nokogiri::XML::Node.new('l', @parser.teiDocument)
     testElement.content = 'iota kap-_pa lambda'

     result = @parser.parseNotaBeneMarkup(testElement, stanzaElement)

     assert_equal(result.to_s, '<l>iota kappa <note>ambiguous hyphenation</note> lambda</l>')

     # «FN1·There was about this Time a man shew'd who wrote with his foot.»;
     testElement = Nokogiri::XML::Node.new('l', @parser.teiDocument)
     testElement.content = 'mu «FN1·xi»; nu'

     result = @parser.parseNotaBeneMarkup(testElement, stanzaElement)

     # «FN1·There was about this Time a man shew'd who wrote with his foot.»;
     testElement = Nokogiri::XML::Node.new('l', @parser.teiDocument)

     # «FN1·«MDUL»

     #testElement.content = 'mu «FN1·«MDUL»xi«MDNM».» nu'
     #result = @parser.parseNotaBeneMarkup(testElement, stanzaElement)
     #assert_equal(result.to_s, '<l>mu <note place="foot">xi</note> nu</l>')

     # Handling for <l>And thus I solve this hard «MDUL»Ph\ae\nomenon«MDNM».</l>
     testElement = Nokogiri::XML::Node.new('l', @parser.teiDocument)
     testElement.content = 'And thus I solve this hard «MDUL»Ph\ae\nomenon«MDNM».'

     result = @parser.parseNotaBeneMarkup(testElement, stanzaElement)

     assert_equal(result.to_s, '<l>And thus I solve this hard <hi rend="underline">Ph&#xE6;nomenon</hi>.</l>')
=end
   end

   def testParsePoem

=begin
     @parser.poem = <<EOF
366-001A   1  |The wise pretend to make it clear,
366-001A   2  'Tis no great loss to lose an ear.
366-001A   3  Why are we then so fond of two,
366-001A   4  When by experience one would do.
366-001A   5  _|'Tis true, say they, cut off the head,
366-001A   6  And there's and end, the man is dead;
366-001A   7  Because among all human race,
366-001A   8  None e'er was known to have a brace;
366-001A   9  But confidently they maintain,
366-001A   10  That where we find the Members twain,
366-001A   11  The loss of one is no such trouble,
366-001A   12  Since t'other will in Strength be double:
366-001A   13  The limb Surviving you may swear,
366-001A   14  Becomes his brothers lawful heir.
366-001A   15  Thus for a trial let me beg of
366-001A   16  Your Rev'rence but to cut one Leg off
366-001A   17  And you shall find by this device
366-001A   18  The other will be stronger twice.
366-001A   19  For ev'ry day you shall be gaining
366-001A   20  New Vigor to the leg remaining:
366-001A   21  So when an Eye hath lost its Brother,
366-001A   22  You see the better with the other:
366-001A   23  Cut off your hand and you may do
366-001A   24  With t'other hand the Work of two:
366-001A   25  Because the Soul her pow'r Contracts,
366-001A   26  And on the Brother Limb «MDUL»reacts«MDNM».
366-001A   27  |But yet the point is not so clear in
366-001A   28  Another Case, the sense of hearing;
366-001A   29  For tho' the place of either Ear
366-001A   30  Be distant as one head can bear;
366-001A   31  Yet Galen most acutely shews you
366-001A   32  (Consult his book «MDUL»de partiam usu,)«MDNM»
366-001A   33  That from each ear as he observes,
366-001A   34  There crept two auditory nerves,
366-001A   35  Not to be seen without a Glass,
366-001A   36  Which near the Os «MDUL»petrosum«MDNM» pass,
366-001A   37  Thence to the Neck, and moving thorough there
366-001A   38  One goes to this, and one to t'other ear.
366-001A   39  Which made my grand-dame always stuff her Ears,
366-001A   40  Both right and left as fellow sufferrers.
366-001A   41  You see my Learning; but to shorten it,
366-001A   42  When my left ear was deaf a fortnigt,
366-001A   43  To t'other ear I felt it coming on
366-001A   44  And thus I solve this hard «MDUL»Ph\\ae\\nomenon«MDNM».
366-001A   45  Tis true a glass will bring supplies
366-001A   46  To weak, or old, or clouded Eyes:
366-001A   47  Your Arms, tho' both your eyes were lost,
366-001A   48  Would guard your nose against a post:
366-001A   49  Without your legs two Legs of Wood
366-001A   50  Are stronger and almost as good:
366-001A   51  And as for Hands there have been those,
366-001A   52  Who wanting both, have us'd their Toes«FN1·There was about this Time a man shew'd who wrote with his foot.»;
366-001A   53  But no Contrivance yet appears,
366-001A   54  To furnish artificial Ears.
EOF

     encodedPoem = '<text>
    <div type="book">
      <div type="poem" xml:id="366-001A">
      <lg type="stanza"><l rend="indent" n="1">The wise pretend to make it clear,</l><l n="2">\'Tis no great loss to lose an ear.</l><l n="3">Why are we then so fond of two,</l><l n="4">When by experience one would do.</l></lg><lg type="stanza"><l rend="indent" n="5">\'Tis true, say they, cut off the head,</l><l n="6">And there\'s and end, the man is dead;</l><l n="7">Because among all human race,</l><l n="8">None e\'er was known to have a brace;</l><l n="9">But confidently they maintain,</l><l n="10">That where we find the Members twain,</l><l n="11">The loss of one is no such trouble,</l><l n="12">Since t\'other will in Strength be double:</l><l n="13">The limb Surviving you may swear,</l><l n="14">Becomes his brothers lawful heir.</l><l n="15">Thus for a trial let me beg of</l><l n="16">Your Rev\'rence but to cut one Leg off</l><l n="17">And you shall find by this device</l><l n="18">The other will be stronger twice.</l><l n="19">For ev\'ry day you shall be gaining</l><l n="20">New Vigor to the leg remaining:</l><l n="21">So when an Eye hath lost its Brother,</l><l n="22">You see the better with the other:</l><l n="23">Cut off your hand and you may do</l><l n="24">With t\'other hand the Work of two:</l><l n="25">Because the Soul her pow\'r Contracts,</l><l n="26">And on the Brother Limb <hi rend="underline">reacts</hi>.</l><l rend="indent" n="27">But yet the point is not so clear in</l><l n="28">Another Case, the sense of hearing;</l><l n="29">For tho\' the place of either Ear</l><l n="30">Be distant as one head can bear;</l><l n="31">Yet Galen most acutely shews you</l><l n="32">(Consult his book <hi rend="underline">de partiam usu,)</hi></l><l n="33">That from each ear as he observes,</l><l n="34">There crept two auditory nerves,</l><l n="35">Not to be seen without a Glass,</l><l n="36">Which near the Os <hi rend="underline">petrosum</hi> pass,</l><l n="37">Thence to the Neck, and moving thorough there</l><l n="38">One goes to this, and one to t\'other ear.</l><l n="39">Which made my grand-dame always stuff her Ears,</l><l n="40">Both right and left as fellow sufferrers.</l><l n="41">You see my Learning; but to shorten it,</l><l n="42">When my left ear was deaf a fortnigt,</l><l n="43">To t\'other ear I felt it coming on</l><l n="44">And thus I solve this hard <hi rend="underline">Ph&#xE6;nomenon</hi>.</l><l n="45">Tis true a glass will bring supplies</l><l n="46">To weak, or old, or clouded Eyes:</l><l n="47">Your Arms, tho\' both your eyes were lost,</l><l n="48">Would guard your nose against a post:</l><l n="49">Without your legs two Legs of Wood</l><l n="50">Are stronger and almost as good:</l><l n="51">And as for Hands there have been those,</l><l n="52">Who wanting both, have us\'d their Toes<note place="foot">There was about this Time a man shew\'d who wrote with his foot.</note></l><l n="53">But no Contrivance yet appears,</l><l n="54">To furnish artificial Ears.</l></lg></div>
    </div>
  </text>'

     @parser.parsePoem
=end

     # result = @parser.parsePoem
     # assert_equal(result.to_xhtml, encodedPoem)
   end

   def testParseHeader

     @parser.heading = <<EOF
Transcription Form  -  25 July 2007
Swift Poems Project

Line below contains formatting deltas


«FM1MD=NM,FT=1,BF=1,SC=1,FL»«FS1«IP0,0»«LS1»
»«OF0»«RM80»«IP0,5»
$$                              Help: SPPDOC
$$                              «MDBO»Filename:«MDNM» 366-001A
$$                              «MDBO»Transcriber & date:«MDNM» JW 22AP09
$$«MDBO»First line:«MDNM» The wise pretend to make it clear
$$«MDBO»Source:«MDNM» MS miscellany, pp. 55-57
$$«MDBO»Library and shelfmark:«MDNM» DLC MS MMC Commonplace book by an unidentified individual, 18th century
$$«MDBO»Proofed by & dates:«MDNM» EBurnor 1JL11 from JW photos; ed. JW 21JA10, 8FE12
EOF

     @parser.parseHeader
   end

   def testParseTitleAndHeadnote

     @parser.titleAndHeadnote = <<EOF
366-001A   Dr Delany wrote to Dr Swift, in order | to be admitted to speak to him when he | was Deaf. to which the Dean sent the | following Answer.
366-001A   HN1 Written in the Year 1724.
366-001A   HN2 
366-001A   HN3 
366-001A   
EOF

     @parser.parseTitleAndHeadnote
   end

   def testParseFootNotes

     @parser.footNotes = <<EOF
366-001A   $$«MDBO»Table of contents title:«MDNM» alpha
^Z
EOF

     #puts @parser.parseFootNotes

     @parser.footNotes = <<EOF
366-001A   $$«MDBO»Attribution:«MDNM» Swift
366-001A   $$«MDBO»Table of contents title:«MDNM» --
366-001A   $$«MDBO»Other title:«MDNM» Not listed in index
366-001A   $$«MDBO»Remarks:«MDNM» MDUL = printed, not cursive, script. 5 and end: literally "andend"
366-001A   $$«MDBO»Sic:«MDNM» 32 «MDUL»partiam«MDNM»   36 Os «MDUL»petrosum«MDNM»   40 sufferrers   42 fortnigt
366-001A   $$«MDBO»To check:«MDNM» --
^Z
EOF

     #puts @parser.parseFootNotes
   end

   def testParse

     #puts @parser.parse
   end

   def testParseFiles

=begin
     # No 366
     ['613-0653', '006-14A7', '006-20L4', '006-!9D-', '006-!9L1', '006-D540', '261-008D', '391-02U1', '553-1951', '357-27L2'].each do |fileName|
     #['613-0653', '006-14A7', '006-20L4', '006-!9D-', '006-!9L1', '006-D540', '261-008D', '391-02U1', '357-27L2'].each do |fileName|
     #['613-0653', '006-14A7', '006-20L4', '006-!9D-', '006-!9L1', '006-D540', '261-008D', '357-27L2'].each do |fileName|

       parser = SwiftPoetryProject::TeiParser.new(fileName)
       #puts parser.parse
     end
=end
   end

   def testParseFNTokens

     # Case 1
     line = '«FN1·alpha»beta«FN1·gamma»'

     lineElem = Nokogiri::XML::Node.new('p', @document)
     @document.at_xpath('tei:TEI/tei:text/tei:body', SwiftPoetryProject::TeiParser::TEI_NS).add_child lineElem

     lineText = Nokogiri::XML::Text.new(line, @document)
     lineElem.add_child lineText

     results = @parser.parseFNTokens lineText

     assert_equal '<p><note n="1" place="foot">alpha</note>beta<note n="2" place="foot">gamma</note></p>', results.to_xml

     # Case 1b
     results.children.select { |c| c.class == Nokogiri::XML::Text }.each do |t|

       assert_not_nil t.parent
     end

     # Case 2
     line = '«FN1·──────«MDUL»Super & Garamantus, & Indos,_Preferet imperium«MDNM»──────────────«MDUL»_«MDNM»──────«MDUL»Jam nunc & Caspia, regna_Responsis horrent Divûm«MDNM»──────»'

     lineElem = Nokogiri::XML::Node.new('p', @document)
     @document.at_xpath('tei:TEI/tei:text/tei:body', SwiftPoetryProject::TeiParser::TEI_NS).add_child lineElem

     lineText = Nokogiri::XML::Text.new(line, @document)
     lineElem.add_child lineText

     results = @parser.parseFNTokens lineText

     assert_equal '<p><note n="3" place="foot">&#x2500;&#x2500;&#x2500;&#x2500;&#x2500;&#x2500;&#xAB;MDUL&#xBB;Super &amp; Garamantus, &amp; Indos,_Preferet imperium&#xAB;MDNM&#xBB;&#x2500;&#x2500;&#x2500;&#x2500;&#x2500;&#x2500;&#x2500;&#x2500;&#x2500;&#x2500;&#x2500;&#x2500;&#x2500;&#x2500;&#xAB;MDUL&#xBB;_&#xAB;MDNM&#xBB;&#x2500;&#x2500;&#x2500;&#x2500;&#x2500;&#x2500;&#xAB;MDUL&#xBB;Jam nunc &amp; Caspia, regna_Responsis horrent Div&#xFB;m&#xAB;MDNM&#xBB;&#x2500;&#x2500;&#x2500;&#x2500;&#x2500;&#x2500;</note></p>', results.to_xml

     results.children.select { |c| c.class == Nokogiri::XML::Text }.each do |t|

       assert_not_nil t.parent
     end

     # Case 3
     line = '«FN1·──────«MDUL»Super & Garamantus, & Indos,_Preferet imperium«MDNM»──────»«FN1·«MDUL»_«MDNM»»'

     lineElem = Nokogiri::XML::Node.new('p', @document)
     @document.at_xpath('tei:TEI/tei:text/tei:body', SwiftPoetryProject::TeiParser::TEI_NS).add_child lineElem

     lineText = Nokogiri::XML::Text.new(line, @document)
     lineElem.add_child lineText

     results = @parser.parseFNTokens lineText

     assert_equal '<p><note n="4" place="foot">&#x2500;&#x2500;&#x2500;&#x2500;&#x2500;&#x2500;&#xAB;MDUL&#xBB;Super &amp; Garamantus, &amp; Indos,_Preferet imperium&#xAB;MDNM&#xBB;&#x2500;&#x2500;&#x2500;&#x2500;&#x2500;&#x2500;</note><note n="5" place="foot">&#xAB;MDUL&#xBB;_&#xAB;MDNM&#xBB;</note></p>', results.to_xml

     results.children.select { |c| c.class == Nokogiri::XML::Text }.each do |t|

       assert_not_nil t.parent
     end

     # Case 4

     line = '«FN1·the late Dutchess of Somerset formerly wife of M«MDSU»r«MDBU» 08. Tho«MDSU»s«MDBU» Thynne who was killed by Count Coningsmark«MDNM»»'

     lineElem = Nokogiri::XML::Node.new('p', @document)
     @document.at_xpath('tei:TEI/tei:text/tei:body', SwiftPoetryProject::TeiParser::TEI_NS).add_child lineElem

     lineText = Nokogiri::XML::Text.new(line, @document)
     lineElem.add_child lineText

     results = @parser.parseFNTokens lineText

     assert_equal '<p><note n="6" place="foot">the late Dutchess of Somerset formerly wife of M&#xAB;MDSU&#xBB;r&#xAB;MDBU&#xBB;&#xA0;08. Tho&#xAB;MDSU&#xBB;s&#xAB;MDBU&#xBB; Thynne who was killed by Count Coningsmark</note></p>', results.to_xml
     

=begin
     # Case 4
     line = "«MDRV»B«MDNM»Y an «MDBU»old red·pate murdring hag «FN1·the late Dutchess of Somerset formerly wife of M«MDSU»r«MDBU» 08. Tho«MDSU»s«MDBU» Thynne who was killed by Count Coningsmark«MDNM»» «MDNM»pursu'd,"
     lineElem = Nokogiri::XML::Node.new('p', @document)

     lineText = Nokogiri::XML::Text.new(line, @document)
     lineElem.add_child lineText
     @document.at_xpath('tei:TEI/tei:text/tei:body', SwiftPoetryProject::TeiParser::TEI_NS).add_child lineElem

     assert_same (@parser.parseFNTokens lineText), lineElem

     puts lineElem.to_xml
     puts lineElem.content
     puts @parser.documentTokens.to_s
=end

   end

   # SPP-10: Implement

   def testParseXMLTextNode

     # Case 1
     line = '<note place="foot">the late Dutchess of Somerset formerly wife of M«MDSU»r«MDBU» 08. Tho«MDSU»s«MDBU» Thynne who was killed by Count Coningsmark«MDNM»</note>'
     lineElem = Nokogiri::XML::Node.new('p', @document)
     @document.at_xpath('tei:TEI/tei:text/tei:body', SwiftPoetryProject::TeiParser::TEI_NS).add_child lineElem

     # Case 2
     line = "«MDRV»B«MDNM»Y an «MDBU»old red·pate murdring hag pursu'd,«MDNM»"
     lineElem = Nokogiri::XML::Node.new('p', @document)
     lineText = Nokogiri::XML::Text.new(line, @document)
     lineElem.add_child lineText
     @document.at_xpath('tei:TEI/tei:text/tei:body', SwiftPoetryProject::TeiParser::TEI_NS).add_child lineElem

     assert_same (@parser.parseFNTokens lineText), lineElem

     # puts "\n\ninitial element: " + lineElem.to_xml

     # Avoiding refactoring this into a recursive process...

     # CDATA -> f() : <l><N-element>CDATA</N-element>CDATA<N1-element>...</l>
     # <l></l> -> f() : 

     lineElem.children.each do |child|

       # assert_not_nil child.parent
       # puts '"child": ' + child.to_xml
       e = (@parser.parseXMLTextNode child)
       # puts 'resulting child: ' + e.to_xml

=begin
       e.children.each do |c|

         # puts 'c: ' + c.to_xml
         # @parser.parseXMLTextNode c

         assert_not_nil c.parent

         puts '"c": ' + c.to_xml
         # @parser.parseXMLTextNode c
       end
=end
     end

=begin
     # Case 3
     line = "«MDRV»B«MDNM»Y an «MDBU»old red·pate murdring hag «FN1·the late Dutchess of Somerset formerly wife of M«MDSU»r«MDBU» 08. Tho«MDSU»s«MDBU» Thynne who was killed by Count Coningsmark«MDNM»» «MDNM»pursu'd,"

     lineElem = Nokogiri::XML::Node.new('p', @document)

     lineText = Nokogiri::XML::Text.new(line, @document)
     lineElem.add_child lineText
     @document.at_xpath('tei:TEI/tei:text/tei:body', SwiftPoetryProject::TeiParser::TEI_NS).add_child lineElem

     assert_same (@parser.parseFNTokens lineText), lineElem

     # Explicit functionality for node sets
     s = Nokogiri::XML::NodeSet.new @document

     lineElem.children.each do |child|

       e = @parser.parseXMLTextNode child
       
       if e.is_a? Nokogiri::XML::Element and e.name == 'p'

         s = s | e.children
       else

         s = s | (Nokogiri::XML::NodeSet.new @document, [e])
       end
     end

     results = Nokogiri::XML::Node.new('p', @document)
     results.add_child s

     assert_equal '<p><hi rend="display-initial">B</hi>Y an old red&#xB7;pate murdring hag <note xmlns="http://www.tei-c.org/ns/1.0" place="foot">the late Dutchess of Somerset formerly wife of M<hi rend="sup">r</hi>&#xA0;08. Tho<hi rend="sup">s</hi> Thynne who was killed by Count Coningsmark</note><hi rend="blackletter"> </hi>pursu\'d,</p>', results.to_xml
=end
     
   end
   
   def testParseForNbBlocks

     # line = '_«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDNM» «MDUL»C\ae\tera desiderantur«MDNM» «MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDNM»'

     # Refactor into a test factory using combinatorics?

     # Case 1: Nota Bene block literal without additional substrings
     line = '«MDSU»*«MDSD»*«MDSU»*«MDNM»'
     lineElem = Nokogiri::XML::Node.new('p', @document)
     @document.at_xpath('tei:TEI/tei:text/tei:body', SwiftPoetryProject::TeiParser::TEI_NS).add_child lineElem

     lineText = Nokogiri::XML::Text.new(line, @document)
     lineElem.add_child lineText

     assert_same (@parser.parseForNbBlocks lineText), lineElem

     assert_equal('<p><unclear reason="illegible"/></p>' ,lineElem.to_xml)

     # Case 2: a<literal>

     line = 'a«MDSU»*«MDSD»*«MDSU»*«MDNM»'
     lineElem = Nokogiri::XML::Node.new('p', @document)

     lineText = Nokogiri::XML::Text.new(line, @document)
     lineElem.add_child lineText
     @document.at_xpath('tei:TEI/tei:text/tei:body', SwiftPoetryProject::TeiParser::TEI_NS).add_child lineElem

     assert_same (@parser.parseForNbBlocks lineText), lineElem

     assert_equal('<p>a<unclear reason="illegible"/></p>' ,lineElem.to_xml)

     # Case 3: <literal>a

     line = '«MDSU»*«MDSD»*«MDSU»*«MDNM»a'
     lineElem = Nokogiri::XML::Node.new('p', @document)

     lineText = Nokogiri::XML::Text.new(line, @document)
     lineElem.add_child lineText
     @document.at_xpath('tei:TEI/tei:text/tei:body', SwiftPoetryProject::TeiParser::TEI_NS).add_child lineElem

     assert_same (@parser.parseForNbBlocks lineText), lineElem

     assert_equal('<p><unclear reason="illegible"/>a</p>' ,lineElem.to_xml)

     # Case 4: <literal>a<literal>

     line = '«MDSU»*«MDSD»*«MDSU»*«MDNM»a«MDSU»*«MDSD»*«MDSU»*«MDNM»'
     lineElem = Nokogiri::XML::Node.new('p', @document)

     lineText = Nokogiri::XML::Text.new(line, @document)
     lineElem.add_child lineText
     @document.at_xpath('tei:TEI/tei:text/tei:body', SwiftPoetryProject::TeiParser::TEI_NS).add_child lineElem

     assert_same (@parser.parseForNbBlocks lineText), lineElem

     assert_equal('<p><unclear reason="illegible"/>a<unclear reason="illegible"/></p>' ,lineElem.to_xml)

     # Case 5: _«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDNM» «MDUL»C\ae\tera desiderantur«MDNM» «MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDNM»

     line = '_«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDNM» «MDUL»C\ae\tera desiderantur«MDNM» «MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDNM»'
     lineElem = Nokogiri::XML::Node.new('p', @document)

     lineText = Nokogiri::XML::Text.new(line, @document)
     lineElem.add_child lineText
     @document.at_xpath('tei:TEI/tei:text/tei:body', SwiftPoetryProject::TeiParser::TEI_NS).add_child lineElem

     assert_same (@parser.parseForNbBlocks lineText), lineElem

     assert_equal('<p>_<unclear reason="illegible"/> &#xAB;MDUL&#xBB;C\ae\tera desiderantur&#xAB;MDNM&#xBB; <unclear reason="illegible"/></p>' ,lineElem.to_xml)

     # Case 6: Project E«MDSU»*«MDSD»*«MDSU»*«MDNM»e and S«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDNM» Schemes «FN1·«MDBU»Excise & South Sea«MDNM»»

     line = 'Project E«MDSU»*«MDSD»*«MDSU»*«MDNM»e and S«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDNM» Schemes «FN1·«MDBU»Excise & South Sea«MDNM»»'
     lineElem = Nokogiri::XML::Node.new('p', @document)

     lineText = Nokogiri::XML::Text.new(line, @document)
     lineElem.add_child lineText
     @document.at_xpath('tei:TEI/tei:text/tei:body', SwiftPoetryProject::TeiParser::TEI_NS).add_child lineElem

     assert_same (@parser.parseForNbBlocks lineText), lineElem
     assert_equal('<p>Project E<unclear reason="illegible"/>e and S<unclear reason="illegible"/> Schemes &#xAB;FN1&#xB7;&#xAB;MDBU&#xBB;Excise &amp; South Sea&#xAB;MDNM&#xBB;&#xBB;</p>', lineElem.to_xml)
   end

   def testCompareNbDocuments

     compareNbDocuments()
   end
end
