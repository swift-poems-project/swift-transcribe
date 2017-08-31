#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'nokogiri'
require 'open-uri'
require 'logger'

require_relative 'SwiftPoemsProject'

require_relative 'TeiPoemHeads'
require_relative 'TeiHead'
require_relative 'TeiLinkGroup'
require_relative 'TeiTitle'
require_relative 'TeiPoem'
require_relative 'TeiStanza'
require_relative 'TeiLine'
require_relative 'NotaBeneDelta'

require_relative 'NotaBeneHeadnoteParser'
require_relative 'NotaBeneTitleParser'

require_relative 'nota_bene_g_drive_store'
require_relative 'tei_encoder'
require_relative 'tei_file_encoder'

module SwiftPoetryProject

  POEM = 'poem'
  LETTER = 'letter'

  # logger = Logger.new(STDOUT)
  # logger.level = Logger::DEBUG

  class TeiParserException < StandardError; end
  class NoteBeneFormatException < TeiParserException; end
  class SwiftPoemsProjectError < StandardError; end

  # \«MDUL»dash·in·left·margin«MDNM»\
  TEI_P5_MANUSCRIPT = <<EOF
<msDesc>
  <additional></additional>
</msDesc>
EOF

  TEI_P5_CORPUS_DOC = <<EOF
<teiCorpus version="5.2" xmlns="http://www.tei-c.org/ns/1.0" xml:lang="en">
  <teiHeader>
    <fileDesc>
      <titleStmt>
        <sponsor>Lafayette College</sponsor>
        <principal>James Woolley</principal>
      </titleStmt>
      <publicationStmt>
        <p>Distributed by Digital Scholarship Services at Lafayette College</p>
      </publicationStmt>
      <sourceDesc>
      </sourceDesc>
    </fileDesc>

<encodingDesc>
    <editorialDecl>
      <correction>
	<p>#{(Nokogiri::XML::Text.new 'To be drafted.', (Nokogiri::XML '<tei/>')).to_xml}</p>
      </correction>
      <normalization>
	<p>#{(Nokogiri::XML::Text.new 'To be drafted.', (Nokogiri::XML '<tei/>')).to_xml}</p>
      </normalization>
    </editorialDecl>
</encodingDesc>
    <profileDesc>
      <langUsage>
        <language ident="en">English</language>
      </langUsage>
    </profileDesc>
  </teiHeader>
</teiCorpus>
EOF

    # The essential elements of the TEI document
    # This assumes that all poems belong to a single corpus (a safe assumption at this point, but not safe for the duration of the project!)
    # It may become necessary to structure individual 
    
    # The entire document is within the English language
    # http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ST.html#STGAla
    
  TEI_P5_DOC = <<EOF
<TEI xmlns="http://www.tei-c.org/ns/1.0" xml:lang="en">
  <teiHeader>
    <fileDesc>
      <titleStmt>
        <sponsor>Lafayette College</sponsor>
        <principal>James Woolley</principal>
      </titleStmt>
      <publicationStmt>
        <p>Distributed by Digital Scholarship Services at Lafayette College</p>
      </publicationStmt>
      <sourceDesc>
        #{TEI_P5_MANUSCRIPT}
      </sourceDesc>
    </fileDesc>

<encodingDesc>
    <editorialDecl>
      <correction>
	<p>#{(Nokogiri::XML::Text.new 'To be drafted.', (Nokogiri::XML '<tei/>')).to_xml}</p>
      </correction>
      <normalization>
	<p>#{(Nokogiri::XML::Text.new 'To be drafted.', (Nokogiri::XML '<tei/>')).to_xml}</p>
      </normalization>
    </editorialDecl>
</encodingDesc>
    <profileDesc>
      <langUsage>
        <language ident="en">English</language>
      </langUsage>
    </profileDesc>
  </teiHeader>
  <text>
<body>
    <div type="book">
      <div>
      </div>
    </div>
</body>
  </text>
</TEI>
EOF


  # The XML TEI namespace
  TEI_NS = {'tei' => 'http://www.tei-c.org/ns/1.0'}

  NB_CHAR_TOKEN_MAP = {
      
    /\\ae\\/ => 'æ',
    /\\AE\\/ => 'Æ',
    /\\oe\\/ => 'œ',
    /\\OE\\/ => 'Œ',
    /``/ => '“',
    /''/ => '”',
    /(?<!«MDNM»|«FN1)·/ => ' ',
    /─ / => '─'    
  }

  # Class for the TEI Document generation
  # This is specific to the Swift Poems Collection
  # @todo Map to either the TEI-Simple (https://github.com/TEIC/TEI-Simple) or TEI Boilerplate
  #
  class TeiParser

    include SwiftPoemsProject
    
    attr_reader :teiDocument, :headerElement, :poemElem, :textElem, :headnote_open
    attr_accessor :poem, :heading, :titleAndHeadnote, :footNotes, :documentTokens, :headnote_opened_index
    
    # Constants
    # The SPP collection index specified in NUMBERS
    # This shall be refactored into a sppCollectionIndex Class
    
    SPP_COLLECTIONS = {
      
      'Swift-Pope Miscellanies (up to Hawkesworth)' => 1..100,
      'Fairbrother editions' => 101..200,
      'Faulkner editions' => 201..259,
      'Other Dublin collections' => 260..300,
      'Hawkesworth editions (and Scottish sequels)' => 301..400,
      "Nichols's supplements" => 401..500,
      "Sheridan's edition" => 501..550,
      "Nichols's editions" => 551..600,
      "Scott's editions" => 601..700,
      'Small collections up through 1727' => 701..800,
      'Small collections 1728--' => 801..900
      
    }

    # The XML TEI namespace
    TEI_NS = {'tei' => 'http://www.tei-c.org/ns/1.0'}
    
    # The default Nota Bene markup terminating token
    NB_MARKUP_TERM = '«MDNM»'
    
    # A hash relating Nota Bene markup tokens to TEI element names, related TEI attribute names, and related TEI attribute values
    # Initial Nota Bene markup token => { terminal Nota Bene markup token =>  { TEI element name => { TEI attribute name => TEI attribute value
    
    # Extend markup for the following:
    # 

    NB_MARKUP_TEI_MAP = {
      
      '«MDUL»' => {
        
        '«MDNM»' => { 'hi' => { 'rend' => 'underline' } }
      },
      
      '«MDBO»' => {
        
        #'«MDNM»' => { 'hi' => { 'rend' => 'bold' } }
        '«MDNM»' => { 'hi' => { 'rend' => 'black-letter' } }
      },
      
      # "These Guidelines make no binding recommendations for the values of the rend attribute; the characteristics of visual presentation vary too much from text to text and the decision to record or ignore individual characteristics varies too much from project to project. Some potentially useful conventions are noted from time to time at appropriate points in the Guidelines. The values of the rend attribute are a set of sequence-indeterminate individual tokens separated by whitespace."
    # http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-att.global.html#tei_att.rend

      '«MDBR»' => {

        '«MDNM»' => { 'hi' => { 'rend' => 'SMALL-CAPS-ITALICS' } }
      },

      '«MDBU»' => {

        #'«MDNM»' => { 'hi' => { 'rend' => 'bold underline' } }
        # NOTE: This is not within the standard TEI (?)
        # (Formerly "special-state")
        '«MDNM»' => { 'hi' => { 'rend' => 'black-letter' } },
        '«MDUL»' => { 'hi' => { 'rend' => 'black-letter' } }
      },

      '«MDDN»' => {
        
        '«MDNM»' => { 'hi' => { 'rend' => 'strikethrough' } }
      },
      
      '«MDRV»' => {

        '«MDNM»' => { 'hi' => { 'rend' => 'display-initial' } },
        '«MDUL»' => { 'hi' => { 'rend' => 'italic-display-initial' } }
      },

      '«MDSD»' => {

        #'«MDNM»' => { 'hi' => { 'rend' => 'subscript' } }
        '«MDNM»' => { 'hi' => { 'rend' => 'SMALL-CAPS' } }
      },

      # Source: 
      
      '«MDSU»' => {
        
        '«MDNM»' => { 'hi' => { 'rend' => 'sup' } },
        '«MDBU»' => { 'hi' => { 'rend' => 'sup' } }
      },

      # For footnotes
      '«FN1·' => {
        
        '»' => { 'note' => { 'place' => 'foot' } },
        '.»' => { 'note' => { 'place' => 'foot' } }
      },

      # Additional footnotes
      '«FN1' => {
        
        '»' => { 'note' => { 'place' => 'foot' } }
      },

      # Additional footnotes
      '«FN1«MDNM»' => {
        
        '»' => { 'note' => { 'place' => 'foot' } }
      },

      # For deltas
      # The begin-center (FC, FL) delta
      '«FC»' => {
      
        '«FL»' => { 'head' => {} }
      },

      # The end-of-center (FL, FL) delta
      '«FL»' => {
      
        '«FL»' => { 'head' => {} }
      },

      # The flush right (FR, FL) delta
      '«FR»' => {
        
        '«FL»' => { 'head' => {} }
      },

      # <gap>
      'om' => {
        
        '.' => { 'gap' => {} }
      }
    }

    # This hash is for Nota Bene tokens which encompass a single line (i. e. they are terminated by a newline character rather than another token)
    NB_SINGLE_TOKEN_TEI_MAP = {

      # The flush right (LD) delta
      '«LD »' => {
      
        'head' => {}
      },

      # Footnotes encompassing an entire line
      '«FN1·»' => {
      
        'note' => { 'place' => 'foot' }
      }
    }

    # NB_CHAR_TOKEN_MAP = {
    #
    #  /\\ae\\/ => 'æ',
    #  /\\AE\\/ => 'Æ',
    #  /\\oe\\/ => 'œ',
    #  /\\OE\\/ => 'Œ',
    #  /``/ => '“',
    #  /''/ => '”',
    #  /(?<!«MDNM»|«FN1)·/ => ' ',
    #  /─ / => '─'
    #
    # }

    NB_UNPARSED_TOKENS = ['«MDNM»']


#    NB_BLOCK_LITERAL_PATTERNS = [
#                                 '«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*_«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*',
#                                 '«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDNM»',
#                                 '«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDNM»',
#                                 '«MDSU»*«MDSD»*«MDSU»*«MDNM»'
#                               ]

    NB_BLOCK_LITERAL_PATTERNS = [
                                 /(«MDSU»\*\*?«MDSD»\*)+«MDSU»\*«MDNM»\*?/,
                                 /#{Regexp.escape("«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»**«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*")}/,
                                 # //
                                 
                                ]

    # POEM_ID_PATTERN = /[\dA-Z]\d{2}[\-\d][\dA-Z\!\-]{4}/
    POEM_ID_PATTERN = /[0-9A-Z\!\-]{8}\s+/

    NB_STORE_PATH = "#{File.dirname(__FILE__)}/master"

    def updateCollectionName(collectionName = nil)

      if @poemID

        @collectionName = getCollection(@poemID[0..2].to_i)
      else

        @collectionName = collectionName
      end
    end

    def clean(lines)

      # Ensures that tokens contained on the footer-delimiting line are shifted to the previous line
      # Resolves SPP-118
      # lines.gsub(/#{Regexp.escape("M442090A   20  ────── Who does no know Sir Isaac and the Dean?")}/, "M442090A   20  ────── Who does no know Sir Isaac and the Dean?«MDUL» «MDNM»")
      lines = lines.gsub(/#{Regexp.escape("M442090A   %%                                                  «MDUL» «MDNM»")}/, "M442090A   %%\r")

      # Resolves issues for ambiguous modecode parsing
      # Please see SPP-113
      lines = lines.gsub(/#{Regexp.escape("640-0202   551  _«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDUL»C\\ae\\tera desiderantur«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDNM»")}/, "640-0202   551  _«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDUL»C\\ae\\tera desiderantur«MDNM»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDNM»")

      lines = lines.gsub(/#{Regexp.escape("391-0251   H«MDNM»N1 Written in the Y«MDSD»EAR«MDNM» 1726.")}/, "391-0251   HN1 Written in the Y«MDSD»EAR«MDNM» 1726.")
      lines = lines.gsub(/#{Regexp.escape("419B0251   HN«MDNM»1 Written in the Y«MDSD»EAR«MDNM» 1730.")}/, "419B0251   HN1 Written in the Y«MDSD»EAR«MDNM» 1730.")
      lines = lines.gsub(/#{Regexp.escape("521-0251   On «MDUL»Stephen Duck«MDNM», the Thresher, | and favourite Poet, | «MDNM»A «MDUL»QUIBBLING EPIGRAM«MDNM».")}/, "521-0251   On «MDUL»Stephen Duck«MDNM», the Thresher, | and favourite Poet, | A «MDUL»QUIBBLING EPIGRAM«MDNM».")
      lines = lines.gsub(/#{Regexp.escape("903-0251   HN«MDNM»1 «MDUL»To an agreeable young Lady, but extremely lean«MDNM».")}/, "903-0251   HN1 «MDUL»To an agreeable young Lady, but extremely lean«MDNM».")

      lines = lines.gsub(/#{Regexp.escape("198-03P5   H«MDNM»ORACE, «MDUL»Lib. «MDNM»2«MDUL». Sat. «MDNM»6.")}/, "198-03P5   HORACE, «MDUL»Lib. «MDNM»2«MDUL». Sat. «MDNM»6.")
      lines = lines.gsub(/#{Regexp.escape("026-07H1   «FN1·When the authors posthumous pieces were reprinted in «MDUL»Ireland«MDNM», this and the foregoing odes were omitted.» ODE | «MDUL»To the Hon«MDBU»ble«MDUL» Sir«MDNM» WILLIAM TEMPLE.")}/, "026-07H1   «FN1·When the authors posthumous pieces were reprinted in «MDUL»Ireland«MDNM», this and the foregoing odes were omitted.» ODE | «MDUL»To the Hon«MDNM»«MDBU»ble«MDNM»«MDUL» Sir«MDNM» WILLIAM TEMPLE.")

      lines = lines.gsub(/#{Regexp.escape("866-0253   The Grand Question debated: | WHETHER | H«MDSD»AMILTON'«MDNM»s«MDSD» «FN1·«MDUL»A «MDNM»B«MDSD»AWN«MDUL» was a Place near the House inclosed with Mud or Stone-Walls, to keep the Cattle from being stolen in the Night. They are now little used«MDNM».» «MDNM»B«MDSD»AWN«MDNM» should be | turned into a «MDUL»Barrack«MDNM» or «MDUL»Malt-house«MDNM».")}/,
                         "866-0253   The Grand Question debated: | WHETHER | H«MDSD»AMILTON'«MDNM»s«MDSD» «FN1·«MDUL»A «MDNM»B«MDSD»AWN«MDNM»«MDUL» was a Place near the House inclosed with Mud or Stone-Walls, to keep the Cattle from being stolen in the Night. They are now little used«MDNM».» B«MDSD»AWN«MDNM» should be | turned into a «MDUL»Barrack«MDNM» or «MDUL»Malt-house«MDNM».")

      lines = lines.gsub(/#{Regexp.escape("348-0253   «FN1·That noted Chief Justice, who twice prosecuted the«MDNM» D«MDSD»RAPIER«MDNM», «MDUL»and dissolved the Grand Jury for not finding the Bill against him«MDNM».» «MDUL»WHITSHED«MDNM»'s Motto on his Coach.")}/, "348-0253   «FN1·That noted Chief Justice, who twice prosecuted the D«MDSD»RAPIER«MDNM», «MDUL»and dissolved the Grand Jury for not finding the Bill against him«MDNM».» «MDUL»WHITSHED«MDNM»'s Motto on his Coach.")

      lines = lines.gsub(/#{Regexp.escape("132-S935   THE | VIRTUES | OF | «MDUL»S«MDBR»ID«MDNM» «MDUL»H«MDBR»AMET«MDNM» the MAGICIAN's | ROD.")}/, "132-S935   THE | VIRTUES | OF | «MDUL»S«MDNM»«MDBR»ID«MDNM» «MDUL»H«MDNM»«MDBR»AMET«MDNM» the MAGICIAN's | ROD.")

      lines = lines.gsub(/#{Regexp.escape("Y34A33D-   A | Friendly Apology | «MDNM»FOR A | Certain Justice of Peace; by way of De- | fence of ────── ────── Esq;")}/, "Y34A33D-   A | Friendly Apology | FOR A | Certain Justice of Peace; by way of De- | fence of ────── ────── Esq;")

      lines = lines.gsub(/#{Regexp.escape("«MDNM»$$«MDBO»Proofed by & dates:«MDNM» JIF 26MY87, 30MY87; √'d JW 15JL93 agt independent transcript by CK 17FE93 (proofed JReiseman 15JL93); √'d JW agt independent transcript by JIF 10MY87; cleaned JW 26MY87, 14AU91; √'d JIF 4MR96 agt 079-21D-; √'d JW 9JA97 agt 002D; ed. JW 16AU01, 9JE14; √'d JW 13SE08 agt WILH")}/, "$$«MDBO»Proofed by & dates:«MDNM» JIF 26MY87, 30MY87; √'d JW 15JL93 agt independent transcript by CK 17FE93 (proofed JReiseman 15JL93); √'d JW agt independent transcript by JIF 10MY87; cleaned JW 26MY87, 14AU91; √'d JIF 4MR96 agt 079-21D-; √'d JW 9JA97 agt 002D; ed. JW 16AU01, 9JE14; √'d JW 13SE08 agt WILH")

      lines = lines.gsub(/#{Regexp.escape("132-11L-   «MDNM»THE | VIRTUES | OF | «MDUL»Sid Hamet«MDNM» the M«MDSD»AGICIAN«MDNM»'«MDUL»s«MDNM» | ROD.")}/, "132-11L-   THE | VIRTUES | OF | «MDUL»Sid Hamet«MDNM» the M«MDSD»AGICIAN«MDNM»'«MDUL»s«MDNM» | ROD.")

      lines = lines.gsub(/#{Regexp.escape("405B04P3   «MDUL»Dr. «MDNM»Sw---«MDUL» to Mr. «MDNM»P---e«MDUL»,")}/, "405B04P3   «MDUL»Dr. «MDNM»Sw---«MDUL» to Mr. «MDNM»P---e,")

      lines = lines.gsub(/#{Regexp.escape("949B11M2   «MDUL»An«MDBO» «MDNM»E«MDSD»PIGRAM«MDNM» «MDUL»on«MDNM» «MDNM»Scolding.")}/, "949B11M2   «MDUL»An«MDBO» «MDNM»E«MDSD»PIGRAM«MDNM» «MDUL»on«MDNM» Scolding.")

      lines = lines.gsub(/#{Regexp.escape("X19B1151   A Copy of a Copy of Verses from T«MDSD»HOMAS | «MDNM»S«MDSD»HERIDAN«MDNM», Clerk, to G«MDSD»EORGE «FN1·«MDNM»G«MDSD»EORGE «MDNM»R«MDSD»OCHFORT«MDNM», Esq;» «MDNM»N«MDSD»IM-«MDNM»«FN1·«MDUL»His Brother«MDNM» J«MDSD»OHN«MDNM» R«MDSD»OCHFORT«MDNM», «MDUL»called«MDNM» N«MDSD»IM«MDNM», «MDUL»because he was a great Hunter, from«MDNM» N«MDSD»IMROD«MDNM».» | «MDNM»D«MDSD»AN-«MDNM»«FN1·«MDUL»The Rev. Mr«MDNM» D«MDSD»ANIEL«MDNM» J«MDSD»ACKSON«MDNM».»D«MDSD»EAN«MDNM»«FN1·«MDUL»Dr«MDNM». S«MDSD»WIFT«MDNM», «MDUL»Dean of St.«MDNM» Patrick's.», Esq; Written «MDUL»July«MDNM» 15th, | 1721, at Night.")}/, "X19B1151   A Copy of a Copy of Verses from T«MDSD»HOMAS | «MDNM»S«MDSD»HERIDAN«MDNM», Clerk, to G«MDSD»EORGE«MDNM» «FN1·G«MDSD»EORGE «MDNM»R«MDSD»OCHFORT«MDNM», Esq;» N«MDSD»IM-«MDNM»«FN1·«MDUL»His Brother«MDNM» J«MDSD»OHN«MDNM» R«MDSD»OCHFORT«MDNM», «MDUL»called«MDNM» N«MDSD»IM«MDNM», «MDUL»because he was a great Hunter, from«MDNM» N«MDSD»IMROD«MDNM».» | D«MDSD»AN-«MDNM»«FN1·«MDUL»The Rev. Mr«MDNM» D«MDSD»ANIEL«MDNM» J«MDSD»ACKSON«MDNM».»D«MDSD»EAN«MDNM»«FN1·«MDUL»Dr«MDNM». S«MDSD»WIFT«MDNM», «MDUL»Dean of St.«MDNM» Patrick's.», Esq; Written «MDUL»July«MDNM» 15th, | 1721, at Night.")

      lines = lines.gsub(/#{Regexp.escape("859-1151   Dean S«MDSD»WIFT«MDNM» at Sir A«MDSD»RTHUR «MDNM»A«MDSD»CHESON«MDNM»'s«MDNM» in | the North of I«MDSD»RELAND«MDNM».")}/, "859-1151   Dean S«MDSD»WIFT«MDNM» at Sir A«MDSD»RTHUR «MDNM»A«MDSD»CHESON«MDNM»'s in | the North of I«MDSD»RELAND«MDNM».")

      lines = lines.gsub(/#{Regexp.escape("Y20-03P2   THE | «MDUL»QUIDNUNCKI'S«MDNM»: | A | TALE. | «MDNM»Occasioned by the D«MDSD»EATH«MDNM» of the | Duke Regent of «MDUL»France«MDNM».")}/, "Y20-03P2   THE | «MDUL»QUIDNUNCKI'S«MDNM»: | A | TALE. | Occasioned by the D«MDSD»EATH«MDNM» of the | Duke Regent of «MDUL»France«MDNM».")

      lines = lines.gsub(/#{Regexp.escape("076-03P2   HN«MDNM»1 «MDUL»To the Tune of the Cutpurse«MDNM».")}/, "076-03P2   HN1 «MDUL»To the Tune of the Cutpurse«MDNM».")

      lines = lines.gsub(/#{Regexp.escape("601-WILH   HN2 The Preface. | «MDRV»I«MDNM» «MDUL»HAVE been long of Opinion, that there is not a more general and greater Mistake, or of worse Consequences through the Commerce of Mankind, than the wrong Judgments they are apt to entertain of their own Talents: I knew a stuttering Alderman in «MDNM»London«MDUL», a great Frequenter of Coffee-Houses; who, when a fresh News-Paper was brought in, constantly seized it first, and read it aloud to his Brother Citizens; but in a Manner, as little intelligible to the Standers-by as to himself. How many Pretenders to Learning expose themselves by chusing to discourse on those very Parts of Science wherewith they are least acquainted? It is the same case in every other Qualification. By the Multitude of those who deal in Rhimes from Half a Sheet to Twenty, which come out every Minute, there must be at least five hundred Poets in the City and Suburbs of «MDNM»London«MDUL»; half as many Coffee-House Orators, exclusive of the Clergy; forty thousand Politicians; and four thousand five hundred profound Scholars: Not to mention the Wits, the Railliers, the Smart Fellows, and Criticks; all as illiterate and impudent as a Suburb Whore. What are we to think of the fine dressed Sparks, proud of their own Personal Deformities, which appear the more hideous by the «MDNM»Contrast«MDUL» of wearing Scarlet and Gold, with what they call «FN1·«MDNM»Wigs with long black Tails, worn for some Years Past. «MDUL»November«MDNM» 1738.«MDUL»» Toupees on their Heads, and all the Frippery of a modern Beau,")}/,
                         "601-WILH   HN2 The Preface. | «MDRV»I«MDNM» «MDUL»HAVE been long of Opinion, that there is not a more general and greater Mistake, or of worse Consequences through the Commerce of Mankind, than the wrong Judgments they are apt to entertain of their own Talents: I knew a stuttering Alderman in «MDNM»London«MDUL», a great Frequenter of Coffee-Houses; who, when a fresh News-Paper was brought in, constantly seized it first, and read it aloud to his Brother Citizens; but in a Manner, as little intelligible to the Standers-by as to himself. How many Pretenders to Learning expose themselves by chusing to discourse on those very Parts of Science wherewith they are least acquainted? It is the same case in every other Qualification. By the Multitude of those who deal in Rhimes from Half a Sheet to Twenty, which come out every Minute, there must be at least five hundred Poets in the City and Suburbs of «MDNM»London«MDUL»; half as many Coffee-House Orators, exclusive of the Clergy; forty thousand Politicians; and four thousand five hundred profound Scholars: Not to mention the Wits, the Railliers, the Smart Fellows, and Criticks; all as illiterate and impudent as a Suburb Whore. What are we to think of the fine dressed Sparks, proud of their own Personal Deformities, which appear the more hideous by the «MDNM»Contrast«MDUL» of wearing Scarlet and Gold, with what they call«MDNM» «FN1·Wigs with long black Tails, worn for some Years Past. «MDUL»November«MDNM» 1738.» «MDUL»Toupees on their Heads, and all the Frippery of a modern Beau,")      
    end

    # Create a parser for a Nota Bene document
    #
    # @param [String] filePath
    # @param [Hash] options
    def initialize(filePath, options = {})

      @filePath = filePath
      @objectPid = options[:objectPid]
    
      @teiDocument = Nokogiri::XML(TEI_P5_DOC, &:noblanks)

      # Should resolve issues related to the parsing of certain unicode characters
      @teiDocument.encoding = 'utf-8'

      @textElem = @teiDocument.at_xpath('tei:TEI/tei:text/tei:body', TEI_NS)

      if filePath
    
        # Read the file and convert the CP437 encoding into UTF-8
        lines = File.read(@filePath, :encoding => 'cp437:utf-8')
      else
      
        lines = options[:lines]
        
        if not lines
          
          # Raise an exception if lines and filePath are nil
          raise Exception.new "Parser instantiated without providing Nota Bene text"
        end
      end

      # There are no poems which are isolated from an identified source
      @bookElem = @textElem.at_xpath('tei:div', TEI_NS)

      @workType = POEM

      # To each <div> shall be delegated a transcription file
      # Extract and strip certain metadata values at the document level
      # Extract the document ID
      @poemElem = @bookElem.at_xpath('tei:div', TEI_NS)

      m = /(.?\d\d\d\-?[0-9A-Z\!\-]{4,5})   /.match(lines)

      # Searching for alternate patterns
      # Y46B45L5
      # Y09C27L3
      m = /([0-9A-Z\!\-]{8})   /.match(lines) if not m

      # «MDBO»Filename:«MDNM» 920-0201
      m = /«MDBO»Filename:«MDNM» ([0-9A-Z\!\-]{7,8}[#\$@]?)/.match(lines) if not m

      m = /«MDBO»Filename:«MDNM» ([0-9A-Z\!\-#\$]{7,8}[#\$@]?)/.match(lines) if not m

      raise NoteBeneFormatException.new "#{@filePath} features an ID of an unsupported format" unless m

      @poemID = m[1]

      lines = clean(lines)

      # Remove the poem ID (and trailing whitespace)
      # Now this is being used for newline detection
      # lines.gsub!(/#{@poemID}   /, '')

      @poemElem['n'] = @poemID

      # Retrieve the collection name from the NUMBERS index
      updateCollectionName

      # cp437 Encoding
      # lines = lines.split("$$\r\n")
      # lines = lines.split(/\$\$\r?\n/)
      lines = lines.split(/\$\$\r?\n\S{8}?\s{3}/)

      # Error handling for heading parsing errors
      raise NotImplementedError.new "Failed to parse the Nota Bene file structure; Is #{@filePath} a Nota Bene document?" if lines.length != 2

      @headerElement = @teiDocument.at_xpath('tei:TEI/tei:teiHeader', TEI_NS)

      # Parsing the heading
      @heading = lines.shift

      # The tokens should be related to a single document
      @documentTokens = []
      @termToken = nil

      # By default, all documents are poems
      @workType = POEM

      # Parse for the title and headnotes

      if lines[0]
        
        lines = lines[0].split(/##\s*\r?\n/) if lines[0].match(/##\s*\r?\n/)

        # Parsing the title and the headnotes
        @titleAndHeadnote = lines.shift

        if @titleAndHeadnote.match(/letter/i)

          @workType = LETTER
        end

        # There are documents which contain annotations only
        if lines[0]
        
          lines = lines[0].split(/%%\r?\n?/)
        else

          lines = @titleAndHeadnote
        end

        # Error handling for title and headnote parsing
        raise NotImplementedError.new "Failed to parse the title and headnotes" if @titleAndHeadnote.nil?

        # Parsing the poem and generating the appropriate TEI elements
        @poem = lines[0]

        @stanzaIndex = 1
        @noteIndex = 1

        # Parsing the footnotes, marginal notes, and other misc. notes
        @footNotes = lines[1]

        if @workType != LETTER and @footNotes.match(/poem/i)
          
          @workType = POEM
        end

      else

        raise NotImplementedError, "Failed to parse Nota Bene title and headnotes #{lines[0]}"
      end

      if @workType == POEM
        
        @poemElem['type'] = 'poem'
      elsif @workType == LETTER
        
        @poemElem['type'] = 'letter'
      end
      
      @headnote_open = false
#    end

      @footnote_index = 0
  end

  def parse

    parseHeader

    # This is necessary
    @poem = TeiPoem.normalize(@poem)
    @poem = TeiPoem.new(@poem, @poemID, @workType, @poemElem, @footnote_index)

    parseTitleAndHeadnote
    parsePoem
    # parseFootNotes
  end

  def parseHeader

    @heading.each_line do |line|

      line.chomp!

      if /& dates?:/.match(line)

        if /Transcriber & date:/.match(line)

          respStmtElem = Nokogiri::XML::Node.new('respStmt', @teiDocument)
          
          nameElem = Nokogiri::XML::Node.new('name', @teiDocument)
          #nameElem.content = /Transcriber & date:«MDNM» (.+) /.match(line)[1]

          m = /Transcriber & date:.?«MDNM.?» (.+) /.match(line)

          if m

            name = m[1]
            nameElem['key'] = name
            respStmtElem.add_child(nameElem)
          end

          respElem = Nokogiri::XML::Node.new('resp', @teiDocument)
          respElem.content = 'transcription'
          respStmtElem.add_child(respElem)

          @headerElement.at_xpath('tei:fileDesc/tei:titleStmt', TEI_NS).add_child(respStmtElem)
        elsif /Proofed by & dates?:/.match(line)
          
          respStmtElem = Nokogiri::XML::Node.new('respStmt', @teiDocument)
          
          nameElem = Nokogiri::XML::Node.new('name', @teiDocument)
          #nameElem.content = /Proofed by & dates:«MDNM» (\w+) /.match(line)[1]

          # Proofed by & dates:«MDNM» √'d JW 20JE07 agt 07H1; TNiese 25JA11
          # name = /Proofed by & dates:.?«MDNM.?» (\w+) ?/.match(line)[1]

          #name = /Proofed by & dates:.?«MDNM.?» (.+)/.match(line)[1]

          # There may be more than one name
          names = /Proofed by & dates:.?«MDNM.?» (.+)/
            .match( "Proofed by & dates:«MDNM» √'d JW 20JE07 agt 07H1; TNiese 25JA11" )[1]
            .sub(/√'d /, '')
            .split(';')
            .each { |s| s.strip! }

          names.each do |name|
            
            nameElem['key'] = name
          
            respElem = Nokogiri::XML::Node.new('resp', @teiDocument)
            respElem.content = 'proof corrected'
          
            respStmtElem.add_child(respElem)
            respStmtElem.add_child(nameElem)
          end
          
          @headerElement.at_xpath('tei:fileDesc/tei:titleStmt', TEI_NS).add_child(respStmtElem)
        elsif /Scanned by & date\:/.match(line)

          # «MDBO»Scanned by & date:«MDNM» AGendler 22JE04
          respStmtElem = Nokogiri::XML::Node.new('respStmt', @teiDocument)

          nameElem = Nokogiri::XML::Node.new('name', @teiDocument)

          m = /Scanned by & date:«MDNM» (.+)/.match(line)

          if m

            name = m[1]
            nameElem['key'] = name
            respStmtElem.add_child(nameElem)
          end

          respElem = Nokogiri::XML::Node.new('resp', @teiDocument)
          respElem.content = 'scanning'
          respStmtElem.add_child(respElem)
        elsif /File prepared by & date\:/.match(line)

          # «MDBO»Scanned by & date:«MDNM» AGendler 22JE04
          respStmtElem = Nokogiri::XML::Node.new('respStmt', @teiDocument)

          nameElem = Nokogiri::XML::Node.new('name', @teiDocument)

          m = /File prepared by & date:«MDNM» (.+)/.match(line)

          if m

            name = m[1]
            nameElem['key'] = name
            respStmtElem.add_child(nameElem)
          end

          respElem = Nokogiri::XML::Node.new('resp', @teiDocument)
          respElem.content = 'Filed prepared by'
          respStmtElem.add_child(respElem)          
        else

          raise NotImplementedError, "Failed to parse the header value #{line}"
        end
      end
    end

    return @headerElement
  end

  def parseFNTokens(originalNode)

    # Raise an exception if the XML node passed has no parent
    lineElem = originalNode.parent
    raise NotImplementedError.new "XML node not related to any XML document: #{originalNode.to_xml}" if not lineElem

    raise NotImplementedError.new "Parent XML node not related to any XML document: #{originalNode.to_xml}" if not lineElem.parent

    line = originalNode.content

    # Work-around for SPP-73
    # Refactor the tokens

    if @isNextLineFn

      # Note: THIS ASSUMES THAT THE LINE ITSELF DOES NOT CONTAIN NESTED FOOTNOTES
      # Ensure that the contents of the footnote are added to the last appended footnote
      text = line.split(/(?<=»)/).each {|s| s.sub!('»','') if (s.count '«') == 0 }.join
      
      node = @teiDocument.root.at_xpath('//TEI:note[@place="foot"][last()]', {'TEI' => 'http://www.tei-c.org/ns/1.0'})
      node.add_child Nokogiri::XML::Node::new 'lb', @teiDocument
      node.add_child Nokogiri::XML::Text::new text, @teiDocument
      @isNextLineFn = false

      lineElem.content = ''

      # Extending the footnote parsing for the pattern «FN1«MDNM»
      # Resolves SPP-73
      #
      # If the line contains with a footnote Nota Bene token...
    elsif line.match(/«FN1·?/) or line.match(/«FN1«MDNM»/)

      lineElem.content = ''
      footNoteBlockOpen = false

      # Extending the footnote parsing for the pattern «FN1«MDNM»
      # Resolves SPP-73
      # ...split the lines into either footnote blocks...

      substrings = line.split(/(?=«FN1·)|(?=«FN1)|(?<=»)|(?=«FN1«MDNM»)/)

      _substrings = []
      substrings = substrings.each_with_index { |s, i|

        # ["«FN1·data«MDUL»", "data»", "data"]

        if (s.count '«') > (s.count '»')

          footNoteBlockOpen = true

          _substrings.push s
        elsif (s.count '«') < (s.count '»') or footNoteBlockOpen

          _substrings.push _substrings.pop + s

          if (s.count '«') < (s.count '»')

            footNoteBlockOpen = false
          end
        else
        
          _substrings.push s
        end
      }

      # line.split(/(?=«FN1·)|(?<=»)/).each do |s|
      _substrings.each do |s|

        # Extending the footnote parsing for the pattern «FN1«MDNM»
        # Resolves SPP-73
        m = s.match(/«FN1(«MDNM»)(.*)/)

        # If this substring contains the initial footnote token...
        m = s.match(/«FN1·?(.*)/) unless m

        if m

          # If there is an unbalanced MDNM token within the substring...
          tokens = s.split(/(?=«)|(?<=»)/).select { |s| s.match /«.+»/ }

          # Extending the footnote parsing for the pattern «FN1«MDNM»
          # Resolves SPP-73

          if m.length > 2

            footNoteContent = m[2]

            # Work-around for SPP-73
            # Refactor the tokens
            # @isNextLineFn = true

          elsif @documentTokens.count '«MDNM»' == 0 and (tokens.count % 2) > 0 and (s.count '«MDNM»' % 2) > 0

            # ...find and remove the unbalanced MDNM token from the substring...

            # "data<A/>data<A>data<A/>data"
            # "data<A>data<A/>data<A>data"

            footNoteContent = m[1].sub(/«MDNM»(\.?»)/, '\1')
          else

            footNoteContent = m[1]
          end

          node = Nokogiri::XML::Node::new 'note', @teiDocument

          # Refactor
          # Handling for <tei:note> elements
          if node.name == 'note'

            node['n'] = @noteIndex
            @noteIndex+=1
          end

          text = footNoteContent.split(/(?<=»)/).each {|s| s.sub!('»','') if (s.count '«') == 0 }.join

          node['place'] = 'foot'
          node.add_child Nokogiri::XML::Text::new text, @teiDocument
        else
          
          node = Nokogiri::XML::Text::new s, @teiDocument
        end

        lineElem.add_child node
      end
    elsif @documentTokens.include? '«FN1·' or @documentTokens.include? '«FN1' # If there was a footnote token initiating block on a new line...

      # _«MDRV»«FN1«MDNM»·«MDUL»O navis, referent in marete_novi Fluctus«MDNM».«MDRV»»«MDNM»
      raise NotImplementedError.new "Parsing for Nota Bene footnote tokens between multiple lines not implemented"

      # ...inspect as to whether or not the line terminates this footnote block...
      # REFACTOR
#      if line.count '»' % 2 > 0
#        
#        node = lineElem.at_xpath('tei:note[last()]', TEI_NS)
#        node.add_child Nokogiri::XML::Text::new m[1], @teiDocument
#      end
    end

    return lineElem
  end

  TEI_P5_MARGINALIA = <<EOF
<p>The manuscript contains the following marginalia:
  <list></list>
</p>
EOF

  def marginal_list_elem

    elem = @teiDocument.at_xpath('//msDesc/additional/p/list')
    unless elem

      addit_elem = @teiDocument.root.at_xpath('//TEI:msDesc/TEI:additional', {'TEI' => 'http://www.tei-c.org/ns/1.0'})

      marginal_elem_set = Nokogiri::XML.fragment TEI_P5_MARGINALIA
      addit_elem.add_child marginal_elem_set

      elem = addit_elem.at_xpath('TEI:p/TEI:list', {'TEI' => 'http://www.tei-c.org/ns/1.0'})
    end

    return elem
  end

  def add_marginal_item(note, line_number)

    ref_elem = Nokogiri::XML::Node.new 'ref', @teiDocument
    ref_elem['target'] = "l[@n='#{line_number}']"

    note_elem = Nokogiri::XML::Node.new 'item', @teiDocument
    note_elem.content = note

    ref_elem.add_child note_elem
    marginal_list_elem().add_child ref_elem
  end

  # originalNode: Nokogiri::XML::Text within either the <tei:l> or <tei:p> elements
  # 

  def parseXMLTextNode(originalNode, parentNode = nil)

    # Refactor
    # If the original node is a <tei:note> element...
    if originalNode.is_a? Nokogiri::XML::Element and originalNode.name == 'note'

      # Set the lineElem to the <tei:note> element
      lineElem = originalNode

      # Retrieve the content from the text node passed as an argument...
      line = originalNode.content
    else

      # Otherwise, select the parent of the XML node, and its content
      lineElem = originalNode.parent
      line = originalNode.content

      # Refactor
      # If the line element passed as the parent of the text node being parsed does not exist, retrieve the parent from the second argument...
      if not lineElem

        if not parentNode

          # ...and if this is nil, raise an exception
          raise NotImplementedError.new "Parent node not passed to the method and the XML is node not related to any XML document: #{originalNode.to_xml}" if not parentNode
        else
        
          # ...and issue a warning to STDERR
          $stderr.puts "Warning: parent note not related to any XML Document: #{originalNode.to_xml}"
          lineElem = parentNode
        end
      end
    end

    # Implementing handling for marginalia notes
    # @todo Restructure for atomic token parsing and phrase parsing
    if /^dash.in.left.margin$/.match line

      last_line_index = @teiDocument.at_xpath('(//TEI:l)[last()]/@n', {'TEI' => 'http://www.tei-c.org/ns/1.0'})

      add_marginal_item line, last_line_index

      line = lineElem.content = ''
      return
    elsif /^(hole.or.)?blot.obscures,.I.imagine,."(.+)"/.match line # For hole/blot obscurations (Resolves SPP-58)

      unclear_m = /^(.*?blot.obscures),.I.imagine,."(.+)"/.match line

      lineElem.name = 'unclear'
      lineElem.remove_attribute 'rend'
      lineElem['reason'] = unclear_m[1]
      lineElem.content = unclear_m[2]

      return lineElem
    end

    # [SPP-5] Bug:
    # (Issue is resolved by interpreting code with Ruby versions >= 2.0.0p0
    # If the node does not contain any NB tokens, return the original node
    return lineElem if not line.match(/(?=«.{1,4}»)/)

    # ...empty the content from the original text node...
    originalNode.content = ''

    # ...and clone the old line element.
    newLineElem = lineElem.clone

    # Parse for Nota Bene tokens
    # To be implemented: refactor with parsePoem
    lineTokens = []

    # Split cases where tokens are concatenated:
    # '«FC»«MDUL»' => ['«FC»', '«MDUL»']
    # Problem specific to Ruby/Nokogiri (?): match will return a non-nil Object for the pattern /(?=«.{1,4}»)/, split will fail to actually split the string for «FN1·»

    #line.split(/(?=«.{1,4}»|·)/).each do |s|
    line.split(/(?=«)/).each do |s|

      s.split(/(?<=»|·)/).each do |poemToken|
        
        # NotaBeneTree
        # <token1>[...]<token2>[...]</token2>[...]</token1>
        if poemToken.match(/«.{1,4}»?/)

          lineTokens.push poemToken
        elsif poemToken.match(/(?!=«)»$/)

          raise NotImplementedError.new "Token-terminating character » found: #{line}"
        end
      end
    end

    # If there are an odd number of tokens within the line...
    if lineTokens.size % 2 > 0

      # ...and there are no tokens from any other lines...
      if @documentTokens.empty?

        # Firstly, ensure that no single tokens are present within the line:
        # ...iterate through each token in order to locate the single token...
        lineTokens.each do |lineToken|

          # ...and if the first two outer line tokens are not a matching token pair...
          # Case 2: [...]<A>[...][</A>][...]<C>
          if NB_SINGLE_TOKEN_TEI_MAP.has_key? lineToken

#            lineTokens.delete_at(lineTokens.index(lineToken))
#            i = lineTokens.index(lineToken)
#            lineTokens.delete_at(i)

#            (lineTokens.index(lineToken) - 1..lineTokens.length - 1).each do |i|
#            (i..lineTokens.length - 1).each do |i|

#              lineTokens.delete_at(i)
#            end

            lineTokens.slice!(lineTokens.index(lineToken)..lineTokens.length)

            # REFACTOR
            xmlElementName = NB_SINGLE_TOKEN_TEI_MAP[lineToken].keys[0]
            
            node = Nokogiri::XML::Node::new xmlElementName, @teiDocument

            NB_SINGLE_TOKEN_TEI_MAP[lineToken][xmlElementName].each_pair do |attr, value|

              node[attr] = value
            end

            # Refactor
            # Handling for <tei:note> elements
            if node.name == 'note'

              node['n'] = @noteIndex
              @noteIndex+=1
            end

            # Insert the content of the Note Bene token
            m = line.match(/(.*?)#{lineToken}(.*?)$/)

#            nodeText = Nokogiri::XML::Text::new line.sub(/#{lineToken}(.*?)$/, '\1'), @teiDocument
            nodeText = Nokogiri::XML::Text::new m[2], @teiDocument
            node.add_child nodeText
            node = parseXMLTextNode nodeText

            if m[1]

              contentSet = Nokogiri::XML::NodeSet::new @teiDocument, [(Nokogiri::XML::Text::new m[1], @teiDocument), node]
            else

              contentSet = Nokogiri::XML::NodeSet::new @teiDocument, [node]
            end

            if lineToken == '«LD »'

              node['rend'] = 'flush-right'
            end

            newLineElem.add_child contentSet

            #lineElem.add_child node
            #line = m[2]

            # These encompass the entire line
            line = ''
          end
        end

        # ...and if this token was not parsed...

        # ...first determine whether or not this is the initial or terminal token:
        # Case 1: <A>[...]<B>[...]</B>[...]
        # Case 2: [...]<B>[...]</B>[...]<A>

        # If there are still an odd number of tokens remaining to be parsed...
        if lineTokens.size % 2 > 0

          # ...and if there are 3 or more tokens remaining to be parsed...
          if lineTokens.size > 1

            # ...and if the first two tokens within lineTokens are a pair, assume that this token lies at the end of the lineTokens array
            if NB_MARKUP_TEI_MAP.has_key? lineTokens[0] and NB_MARKUP_TEI_MAP[lineTokens[0]].has_key? lineTokens[1]
              
              singleToken = lineTokens.pop
            else # ...otherwise, assume that this token is the first in the array

              singleToken = lineTokens.shift
            end
          else # ...and if only 1 token remains, then simply remove the token from the lineTokens array
            
            singleToken = lineTokens.pop
          end

          # If a single token was isolated...
          if singleToken

            if not NB_UNPARSED_TOKENS.include? singleToken

              # ...if this token initiates another Nota Bene block...

              if NB_MARKUP_TEI_MAP.has_key? singleToken

                # ...add it for the next line.

                @documentTokens.unshift singleToken
                
                # ...remove the last instance of the token from the line
                i = -1
                tokens = line.split(/(?=#{singleToken})|(?<=#{singleToken})/)

                # Not Ruby-friendly
                # Refactor
                while tokens[i] != singleToken

                  i-=1
                end
                tokens.delete_at(i)
                originalNode.content = tokens.join
                  
                line = originalNode.content
              else
              
                # ...and if this is not found, raise an exception:
                raise NotImplementedError.new "Parsing not implemented for the single Nota Bene token #{singleToken}: #{line}"
              end
            else
              
              $stderr.puts "Warning: Not parsing the single token #{singleToken}: #{line}"
              return
            end
          end
        end
      else #...and there are tokens from other lines...

        if not @documentTokens.empty?

          # ...if the token from a previous line began a Nota Bene "block" and the terminal token for this line matches this token...
          # Case: <B>[...]</B></A>
          if NB_MARKUP_TEI_MAP.has_key? @documentTokens[0] and NB_MARKUP_TEI_MAP[@documentTokens[0]].has_key? lineTokens.last
          
            # ...prepend the line tokens with this token
            lineTokens.unshift @documentTokens.shift
            line = lineTokens[0] + line
          end
        end
      end
    end

    # Once there are an even number of tokens in this line...

    i = 0 ; j = 1
    k = 0 ; n = lineTokens.size - 1
    
    # "<A>string<B>string<A>string<B>"
    # Node
    
    nodes = []

    if lineTokens.size != 1 and not lineTokens.empty?

      # This effectivey nullifies the Text node passed by the parent within the lineElement
      # lineElem.content = ''

#      newLineElem.content = ''
    end

    while lineTokens.size != 1 and not lineTokens.empty?

      # Initially, determine whether or not to parse the initial two or outer two tokens as a single tag:
      
      # If the first two line tokens are a matching token pair...
      # Case 1: <A>[...]</A>[[...]<B>[...][</B>]]
      if NB_MARKUP_TEI_MAP.has_key? lineTokens[0] and NB_MARKUP_TEI_MAP[ lineTokens[0] ].has_key? lineTokens[1]
        
        initToken = lineTokens.shift
        termToken = lineTokens.shift
      else
        
        # If the first two line tokens are not a matching token pair...
        # Case 2: <A>[...]<B>[...]</B>[...]</A>
        initToken = lineTokens.shift
        termToken = lineTokens.pop
      end

      # Extending footnote handling...
      if not NB_MARKUP_TEI_MAP.has_key? initToken

        # NotImplementedError: Parsing not implemented for the Nota Bene token «MDNM»: «MDNM»·«MDUL»O navis, referent in marete ([])
        raise NotImplementedError.new "Parsing not implemented for the Nota Bene token #{initToken}: #{line} (#{lineTokens.to_s})"
      elsif not NB_MARKUP_TEI_MAP[initToken].has_key? termToken

        raise NotImplementedError.new "Parsing not implemented for the Nota Bene tags #{initToken} #{termToken}: #{line}"
      end

      # REFACTOR
      xmlElementName = NB_MARKUP_TEI_MAP[initToken][termToken].keys[0]
      
      node = Nokogiri::XML::Node::new xmlElementName, @teiDocument
      
      NB_MARKUP_TEI_MAP[initToken][termToken][xmlElementName].each_pair do |attr, value|
        
        node[attr] = value
      end

      # Refactor
      # Handling for <tei:note> elements
      if node.name == 'note'

        node['n'] = @noteIndex
        @noteIndex+=1
      end

      # Insert the content of the Note Bene token
      m = line.match(/#{initToken}(.*?)#{termToken}/)
      if m

        # node.content = m[1]
        nodeText = Nokogiri::XML::Text::new m[1], @teiDocument
        node.add_child nodeText

        parseXMLTextNode nodeText
      elsif not line.empty? # Ensure that the line being parsed isn't empty

        raise NotImplementedError.new "#{initToken} and #{termToken} could not be extracted from the following line: #{line}"
      end

      # This is problematic for cases in which the tokens contain the outermost content
      m = line.match(/(.*?)#{initToken}(.*?)#{termToken}(.*)/)
      if m

        if line.match(/^#{initToken}(.*?)#{termToken}(.*)$/) or (m[1] != '' and m[3] != '')

          newLineElem.add_child Nokogiri::XML::Text::new m[1], @teiDocument
          newLineElem.add_child node

          parseXMLTextNode node

          # [SPP-27] For the anomalous cases of «MDRV»
          # Refactor
          if initToken == '«MDRV»'

            line = termToken + m[3]
          else

            line = m[3]
          end
        elsif m[1] and m[2]

          newLineElem.add_child Nokogiri::XML::Text::new m[1], @teiDocument
          newLineElem.add_child node
          parseXMLTextNode node

          # [SPP-27] For the anomalous cases of «MDRV»
          # Refactor
          if initToken == '«MDRV»'
            
            line = termToken + m[3]
          else

            line = m[3]
          end
        elsif m[2]

          # In those cases where the Nota Bene tokens encompass the entire line...

          # [SPP-27] For the anomalous cases of «MDRV»
          # Refactor
          if initToken == '«MDRV»'
            
            line = termToken + m[2]
          else

            line = m[2]
          end
        else

          raise NotImplementedError.new "Token handling not implemented for the following line: #{line}"
        end
      end

      # Refactor
      # Handling for <tei:note> elements
      if node.name == 'note'

        node['n'] = @noteIndex
        @noteIndex+=1
      end

      # Shift the SMALL-CAPS strings into the lower case
      if node['rend'] == 'SMALL-CAPS'
        
        node.content = node.content.downcase
        #node.content.downcase!
      end
    end

    termTextElem = Nokogiri::XML::Text::new line, @teiDocument

    newLineElem.add_child termTextElem
    parseXMLTextNode termTextElem
    # lineElem.add_child Nokogiri::XML::Text::new m[3], @teiDocument if m

    # There may be cases for which the following is true:
    # "[...]<A>[...]<B>[...]</B>[...]\n"
    # "[...]</A>[...]<C>[...]</C>[...]"
    
    # If there is a token which has not been parsed...
    if not lineTokens.empty?
      
      # ...assume that this token initiates a Nota Bene block, and prepend it to the document tokens
      @documentTokens.unshift lineTokens.pop
    end

    # Work-around
    # Resolves SPP-57
    # @todo Restructure into parseXMLTextNode
    if node and node.name == 'hi' and node.content == ''

      node.remove
    end

    # return lineElem
    return newLineElem
  end

  def parseTitleAndHeadnote

    # Single parser instance must be utilized for multiple lines
    # @todo Refactor and restructure the parsing process
    headnote_parser = NotaBeneHeadnoteParser.new self, @poemID, @titleAndHeadnote, nil, { :footnote_index => @footnote_index }

    @titleAndHeadnote = @titleAndHeadnote.gsub /#{Regexp.escape("HN2 «MDRV»T«MDUL»HE Author of the following Poem, is said to be Dr. «MDNM»J. S. D. S. P. D«MDUL». who writ it, as well as several other Copies of Verses of the like Kind, by Way of Amusement, in the Family of an honourable Gentleman in the North of «MDNM»Ireland«MDUL», where he spent a Summer about two or three Years ago.")}\n/, "HN2 «MDRV»T«MDUL»HE Author of the following Poem, is said to be Dr. «MDNM»J. S. D. S. P. D«MDUL». who writ it, as well as several other Copies of Verses of the like Kind, by Way of Amusement, in the Family of an honourable Gentleman in the North of «MDNM»Ireland«MDUL», where he spent a Summer about two or three Years ago.«MDNM»\n"

    @titleAndHeadnote = @titleAndHeadnote.gsub /#{Regexp.escape("866-0252   HN2 «MDRV»T«MDUL»HE Author of the following Poem is said to be Dr. «MDNM»J.S. D.S.P.D.«MDUL» who writ it, as well as several other Copies of Verse of the like Kind, by Way of Amusement, in the Family of an honourable Gentleman in the North of «MDNM»Ireland«MDUL», where he spent a Summer about two or three Years ago.")}\r\n#{Regexp.escape("866-0252   «MDNM»HN3")}/, "866-0252   HN2 «MDRV»T«MDUL»HE Author of the following Poem is said to be Dr. «MDNM»J.S. D.S.P.D.«MDUL» who writ it, as well as several other Copies of Verse of the like Kind, by Way of Amusement, in the Family of an honourable Gentleman in the North of «MDNM»Ireland«MDUL», where he spent a Summer about two or three Years ago.«MDNM»\r\n866-0252   HN3"

    @titleAndHeadnote = @titleAndHeadnote.gsub /#{Regexp.escape("866-0251   HN2 «MDRV»T«MDUL»HE Author of the following Poem, is said to be Dr. «MDNM»J. S. D. S. P. D«MDUL». who writ it, as well as several other Copies of Verses of the like Kind, by Way of Amusement, in the Family of an honourable Gentleman in the North of «MDNM»Ireland«MDUL», where he spent a Summer about two or three Years ago")}\r\n#{Regexp.escape("866-0251   «MDNM»HN3")}/, "866-0251   HN2 «MDRV»T«MDUL»HE Author of the following Poem is said to be Dr. «MDNM»J.S. D.S.P.D.«MDUL» who writ it, as well as several other Copies of Verse of the like Kind, by Way of Amusement, in the Family of an honourable Gentleman in the North of «MDNM»Ireland«MDUL», where he spent a Summer about two or three Years ago«MDNM»\r\n866-0251   HN3"

    @titleAndHeadnote = @titleAndHeadnote.gsub /#{Regexp.escape("866-0251   HN3 ")}\t#{Regexp.escape("«MDUL»A certain very great Person, then in that Kingdom, having heard much of this Poem, obtained a Copy from the Gentleman, or, as some say, the Lady, in whose House it was written, from whence, I know not by what Accident, several other Copies were transcribed, full of Errors. As I have a great Respect for the supposed Author, I have procured a true Copy of the Poem, the Publication whereof can do him less Injury than printing any of those incorrect ones which run about in Manuscript, and would infallibly be soon in the Press, if not thus prevented.")}\r\n#{Regexp.escape("866-0251   «MDNM»HN4")}/, "866-0251   HN3 «MDUL»A certain very great Person, then in that Kingdom, having heard much of this Poem, obtained a Copy from the Gentleman, or, as some say, the Lady, in whose House it was written, from whence, I know not by what Accident, several other Copies were transcribed, full of Errors. As I have a great Respect for the supposed Author, I have procured a true Copy of the Poem, the Publication whereof can do him less Injury than printing any of those incorrect ones which run about in Manuscript, and would infallibly be soon in the Press, if not thus prevented.«MDNM»\r\n866-0251   HN4"

    # For imbalanced tokens within the title of each poem...
    @titleAndHeadnote = @titleAndHeadnote.gsub /#{Regexp.escape("516-0202   «MDUL»An Excellent new «MDNM»Ballad«MDUL»; or the true | «MDNM»English«MDUL» «FN1·«MDNM»────Sawbridge, «MDUL»Dean of «MDNM»Ferns«MDUL», lately deceased«MDNM».» Dean to be hanged for a«MDNM» | Rape.")}/, "516-0202   «MDUL»An Excellent new «MDNM»Ballad«MDUL»; or the true | «MDNM»English «FN1·────Sawbridge, «MDUL»Dean of «MDNM»Ferns«MDUL», lately deceased«MDNM».» «MDUL»Dean to be hanged for a«MDNM» | Rape."

    @titleAndHeadnote = @titleAndHeadnote.gsub /#{Regexp.escape("584-46L1   S«MDSD»TREPHON«MDNM» and«MDNM» C«MDSD»HLOE«MDNM».")}/, "584-46L1   S«MDSD»TREPHON«MDNM» and C«MDSD»HLOE«MDNM»."

    # For each line containing the title and head-note fields...
    @titleAndHeadnote.each_line do |line|

      # ...remove the poem ID
      line.chomp!
      line.sub!(POEM_ID_PATTERN, '')
      line.strip!

      # ...continue to the next line if the line is empty or simply consists of the string "--"
      if line == '' or line == '--'

        next
      end

      # Omit lines containing HN and -- for Headnote values
      # (These values do not map to any Element within a given TEI schema

      # This needs to be extended for header content which spans multiple lines

      if not @headnote_open and not /HN\d+/.match(line)

        # @todo Refactor
        title_parser = NotaBeneTitleParser.new(self, @poemID, line, nil, { :footnote_index => @footnote_index })
        title_parser.parse
        title_parser.correct

        @footnote_index = title_parser.footnote_index
      else
        headnote_parser.footnote_index = @footnote_index

        # Work-around
        # @todo Refactor
        @headnote_open = true

        #  /HN\d/.match(line) # Create the header element
        headnote_parser.parse line
        @footnote_index = headnote_parser.footnote_index
      end
    end

    return @headerElement
  end

  def getNotaBeneElemContent(nbMarkupToken, nbMarkupTermToken, line)

    #nbMarkupPattern = /#{nbMarkupToken}(.*)#{nbMarkupTermToken}/

    m = line.match(/#{ nbMarkupToken.sub('.','\.') }(.*?)#{ nbMarkupTermToken.sub('.','\.') }/)
    if not m

      return line
    end

    return m[1]

  end

  def getXmlForLine(line, elemName)

    xml = line

    NB_MARKUP_TEI_MAP.each_key do |nbMarkupToken|

      NB_MARKUP_TEI_MAP[nbMarkupToken].each_key do |nbMarkupTermToken|
        
        teiElementName = NB_MARKUP_TEI_MAP[nbMarkupToken][nbMarkupTermToken]
        teiElementName = teiElementName.keys[0]
        teiAttribName = NB_MARKUP_TEI_MAP[nbMarkupToken][nbMarkupTermToken][teiElementName].keys[0]

        m = /#{nbMarkupToken.sub('.', '\.')}/.match(xml)

        # If we find the token...
        if m

          m = /#{nbMarkupToken.sub('.', '\.')}(.*?)#{nbMarkupTermToken.sub('.', '\.')}/.match(xml)

          if m

            #xml.sub!(/#{nbMarkupToken.sub('.', '\.')}(.*)#{nbMarkupTermToken.sub('.', '\.')}/,"<#{teiElementName} #{teiAttribName}=\"#{NB_MARKUP_TEI_MAP[nbMarkupToken][nbMarkupTermToken][teiElementName][teiAttribName]}\">\1</#{teiElementName}>")

            xml.sub!(/#{nbMarkupToken.sub('.', '\.')}(.*)#{nbMarkupTermToken.sub('.', '\.')}/,"<#{teiElementName} #{teiAttribName}=\"#{NB_MARKUP_TEI_MAP[nbMarkupToken][nbMarkupTermToken][teiElementName][teiAttribName]}\">"+m[1]+"</#{teiElementName}>")
          else

            m = xml.match(/#{nbMarkupToken.sub('.', '\.')}(.*?)/)
            xml.sub!(/#{nbMarkupToken.sub('.', '\.')}(.*)/,"<#{teiElementName} #{teiAttribName}=\"#{NB_MARKUP_TEI_MAP[nbMarkupToken][nbMarkupTermToken][teiElementName][teiAttribName]}\">"+m[1]+"</#{teiElementName}>")

            #xml.sub!(/#{nbMarkupToken.sub('.', '\.')}(.*)/,"<#{teiElementName} #{teiAttribName}=\"#{NB_MARKUP_TEI_MAP[nbMarkupToken][nbMarkupTermToken][teiElementName][teiAttribName]}\">\1</#{teiElementName}>")

            if not m

              raise NotImplementedError.new 'Regular expression failed: '+xml+' for '+nbMarkupToken
            end
          end
        end
      end
    end

    xml = '<'+elemName+'>' + xml + '</'+elemName+'>'
    return xml
  end

  # The method for retrieving a collection name for a given collection index
  # This shall be refactored into a sppCollectionIndex Class

  def parseNotaBeneToken(nbMarkupToken, nbMarkupTermToken, elem)

    parsedElem = Nokogiri::XML(getXmlForLine(elem.content, elem.name), &:noblanks).root

    if elem.has_attribute? 'n'
      
      parsedElem['n'] = elem['n']
    end

    return parsedElem
  end


  def parseAmbigHyphen(lineElement)

    # Editorial interpolations

    line = lineElement.content

     pattern = / (.*)\-(\||_)(.*) /

     m = line.match(pattern)

     if m
     #if m.match(pattern)

       word = m[1] + m[3]

       lines = line.split(/ .*\-(\||_).* /)

       lineElement.content = ''

       noteElement = Nokogiri::XML::Node.new('note', @teiDocument)
       #noteElement.content = m[1]
       noteElement.content = 'ambiguous hyphenation'

       # iota kap-pa lambda
       # iota + kappa + <note> + lambda
       #lines[0] + word

       if lines.size > 0

         lineElement.add_child(Nokogiri::XML::Text.new(lines[0] + ' ' + word + ' ', @teiDocument))
       end

       lineElement.add_child(noteElement)

       if lines.size > 1

         lineElement.add_child(Nokogiri::XML::Text.new(' ' + lines[2], @teiDocument))
       end      
     end

     return lineElement
   end

   def parseEditInterp(lineElement)

     # Editorial interpolations

     line = lineElement.content

     pattern = /\\(.{3,})\\/

     m = line.match(pattern)

     if m

       #editInterp = m[1]
       lines = line.split(pattern)
       lineElement.content = ''

       noteElement = Nokogiri::XML::Node.new('note', @teiDocument)
       noteElement.content = m[1]

       if lines.size > 0

         lineElement.add_child(Nokogiri::XML::Text.new(lines[0], @teiDocument))
       end

       lineElement.add_child(noteElement)

       if lines.size > 1

         lineElement.add_child(Nokogiri::XML::Text.new(' '+lines[1], @teiDocument))
       end      
     end

     return lineElement
   end

   def parseNotaBeneTextMarkup(element)

     element.children.each do |child|

       if child.is_a? Nokogiri::XML::Text

         # Handling for apostrophes and contractions
         child.content = child.content.gsub(/(?<=\s|^)'/, '’')
         child.content = child.content.gsub(/(?<=\w)'/, '‘')
         
         # Implementing support for extended superscript styles
         # Superscript styles are implemented using an initial backspace character (\u00A008 from the parsed Nota Bene)
         m = child.content.match(/\u00A008(.+?)\W/)

         # Ensure that the token is _NOT_ a comma
         # ...also ensure that the token is _NOT_ a period
         if m and m[1] != ',' and m[1] != '.'

           # If one or more underscore characters follow the backspace, render the previous superscript as underlined
           if /_+/.match(m[1])

             child.previous_sibling()['rend'] = child.previous_sibling()['rend'] + ' underline'
           else

             # raise NotImplementedError.new "Support for the following superscript characters not yet implemented: #{child.content}"
             raise NotImplementedError.new "Support for the following superscript characters not yet implemented: #{m[1]} (#{child.content})"
           end

           child.content = child.content.sub(/\u00A008#{m[1]}/, '')
         end
       else

         #child.swap parseAmbigHyphen parseEditInterp child
         child = parseAmbigHyphen parseEditInterp child
         parseNotaBeneTextMarkup child
       end
     end

     return element
   end

   # For parsing Nota Bene markup
   def parseNotaBeneMarkup(stanzaElement)

     stanzaElement.children.each do |lineElement|

       # Extract the line string from the TEI line element
       line = lineElement.content

       return lineElement if line.strip == ''
       
       if line == 'om.'
         
         lineElement.content = ''
         lineElement.add_child(Nokogiri::XML::Node.new('gap', @teiDocument))
       end

       # Handling for triplets
       if lineElement.content.match(/3\}$/)

         stanzaElement['type'] = 'triplet'
         # lineElement.content = lineElement.content.sub(/ 3\}/, '')
       end

       parseNotaBeneTextMarkup lineElement
     end

     return stanzaElement
   end

   def parseForNbBlocks(lineNode)

     nBBlocksPresent = false

     lineElem = lineNode.parent

     raise NotImplementedError.new "TEI element is not appended to a Document: #{lineNode.content}" if not lineElem

     line = lineNode.content

     # @todo Refactor
     # '«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDNM»'
     # '«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»**«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*'
     # '*«MDSD»*«MDSU»**«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDNM»'
     [
      '«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDNM»',
      '«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»**«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*',
      '*«MDSD»*«MDSU»**«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDNM»'
     ].each do |decorative_literal|

       if line.index decorative_literal

         # line = line.sub '«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDSU»*«MDNM»*«MDNM»', ''
         line = line.sub decorative_literal

         blockLiteralElem = Nokogiri::XML::Node.new 'unclear', @teiDocument
         blockLiteralElem['reason'] = 'illegible'
         lineElem.add_child blockLiteralElem
       end
     end

     # Iterate through the patterns for Nota Bene block literals...
     NB_BLOCK_LITERAL_PATTERNS.each do |patternStr|

       patternStr = Regexp.escape patternStr

       # ...and if there is a match...
       pattern = Regexp.new patternStr

       m = line.match pattern

       if m

         if not nBBlocksPresent

           # Please note that lineNode is now, essentially, nullified:
           lineElem.content = ''

           # ...ensure that recursion is undertaken (as, each text may contain other patterns)...
           nBBlocksPresent = true
         end

         subStrings = line.split Regexp.new "(?=#{patternStr})|(?<=#{patternStr})"

         if not subStrings.empty?

           line = ''

           # ...and iterate through the substrings surrounding the Nota Bene block
           subStrings.each do |s|
             
             # "<A>data<B>".split(/<A>/) => ["", "data<B>"]
             # "data<A>data<B>".split(/<A>/) => ["data", "data<B>"]
             
             # If there is a substring, create a text element
             if s.match pattern
               
               blockLiteralElem = Nokogiri::XML::Node.new 'unclear', @teiDocument
               blockLiteralElem['reason'] = 'illegible'
               lineElem.add_child blockLiteralElem
             elsif s.strip != ''
               
               # This is where recursion becomes necessary: "<A>data<A>" => <xml> [ <xml/>, <"data"/>, <xml/>] </xml>
               
               lineText = Nokogiri::XML::Text.new(s, @teiDocument)
               # Recurse for text containing other block literals
               lineElem.add_child lineText

               parseForNbBlocks lineText
               # parseForNbBlocks lineElem
             end
           end
         end
       end
     end



     return lineElem
   end

   def getLineIndex(line)

     # Attempt to extract the line number from the index specified at the beginning of the line
     m = /(\d+)  /.match(line)

     if m

       lineIndex = m[1]
     elsif _lineIndex

       lineIndex = _lineIndex
     else

       # Attempt to retrieve the line index by parsing the TEI Document
       lastLineElems = @poemElem.xpath('tei:' + @blockElemName + '[last()]/tei:' + @lineElemName + '[last()]', TEI_NS)

       if lastLineElems.size > 0

         # If the index was specified for the last line appended to the poem/letter stanza body, increment it by 1
         lineIndex = (lastLineElems.shift['n'].to_i + 1).to_s
       else

         # If the index was specified for the last line appended to the entire poem/letter body, increment it by 1
         lastLineElems = @poemElem.xpath('tei:' + @lineElemName + '[last()]', TEI_NS)

         if lastLineElems.size > 0
           
           lineIndex = (lastLineElems.shift['n'].to_i + 1).to_s
         elsif @lineElemName == 'p' # Refactor
           
           lineIndex = @lineIndex.to_s
           @lineIndex += 1
         end
       end
     end

     # Store the individual line index and store it into the @n attribute of the <p> element
     # http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ST.html#STGAid

     lineIndex = 1.to_s
     return lineIndex
   end

   def parsePoem
     poem.parse
     poem.correct
     @teiDocument
   end

   def stripNotaBeneTokens(str)

     str = str.gsub(/(«.{1,4}(·| )?»)/,'') if str

     return str
   end

   def parseAttributionFootNote(line)

     # Parse for the value of the "Attribution" field
     m = /Attribution:«MDNM» (.+)/.match(line)
     if m and m[1].strip != '--'

       authorText = m[1]

       # In some cases the Nota Bene documents link field values

       # Handling cases in which the field "title" is specified
       m = /title/.match(authorText.strip)

       if m

         titleElem = @headerElement.at_xpath("tei:fileDesc/tei:titleStmt/tei:title", TEI_NS)

         raise TeiParserException.new "Could not find the <title> element within the TEI header: #{titleElem}" if titleElem.nil?

         title = titleElem.content
         authorText = stripNotaBeneTokens(title)
         
         # When handling the content of the editor's annotations, text can only be parsed to a certain complexity

         if /By (.+)/.match(authorText)

           m = /By (.+)/.match(authorText)

           # Remove the terminating period
           authorText = m[1].gsub!(/\.$/, '')

         elsif /title of (.+)\)?/.match(authorText)

           # @todo Refactor
           # For handling linking between Documents
           documentMatch = / (?:to|of) ([0-9A-Z]{3}\-?[0-9A-Z]{4})/.match authorText

           if documentMatch

             # Construct the URI for the XPointer
             linkedPoemId = "#{documentMatch[1]}"
             ptrTargetUri = "info:fedora/#{@objectPid}/TEI#xpath1(//div[@n='#{linkedPoemId}'])"

             ptrElem = Nokogiri::XML::Node.new('ptr', @teiDocument)
             ptrElem['target'] = ptrTargetUri
             
             # Locate the <head> element to be linked
             # (If this <head> element hasn't been appended, append it)
             # @todo Refactor

             headElem = @poemElem.at_xpath("tei:head[@n='#{m[1]}']", TEI_NS)
             if not headElem

               # @todo Refactor
               # @textElem.at_xpath("tei:front", TEI_NS).add_child ptrElem
               frontElem = @textElem.at_xpath("tei:front", TEI_NS)
               if not frontElem

                 # @todo Refactor
                 frontElem = Nokogiri::XML::Node.new('front', @teiDocument)
                 @textElem.add_previous_sibling(frontElem)
               end
               
               # Add the new header elee
               # @todo Refactor
               headElem = Nokogiri::XML::Node.new('head', @teiDocument)
               frontElem.add_child(headElem)
             end

             headElem.add_child ptrElem
           end           
         else

           # @todo Handle more complex cases in which the author's name can be extracted
         end
       else

         # Handling cases in which the field "HN" is specified
         m = /HN(\d)/.match(authorText)

         if m

           # For handling linking between Documents
           documentMatch = / (?:to|of) ([0-9A-Z]{3}\-?[0-9A-Z]{4})/.match authorText

           if documentMatch

             # Construct the URI for the XPointer
             linkedPoemId = "#{documentMatch[1]}"
             ptrTargetUri = "info:fedora/#{@objectPid}/TEI#xpath1(//div[@n='#{linkedPoemId}'])"

             ptrElem = Nokogiri::XML::Node.new('ptr', @teiDocument)
             ptrElem['target'] = ptrTargetUri
             
             # Locate the <head> element to be linked
             # (If this <head> element hasn't been appended, append it)
             # @todo Refactor

             headElem = @poemElem.at_xpath("tei:head[@n='#{m[1]}']", TEI_NS)
             if not headElem

               # @todo Refactor
               # @textElem.at_xpath("tei:front", TEI_NS).add_child ptrElem
               frontElem = @textElem.at_xpath("tei:front", TEI_NS)
               if not frontElem

                 # @todo Refactor
                 frontElem = Nokogiri::XML::Node.new('front', @teiDocument)
                 @textElem.add_previous_sibling(frontElem)
               end
               
               # Add the new header elee
               # @todo Refactor
               headElem = Nokogiri::XML::Node.new('head', @teiDocument)
               frontElem.add_child(headElem)
             end

             headElem.add_child ptrElem
           else

             # authorText = @poemElem.at_xpath("tei:head[@n='#{m[1]}']/text()", TEI_NS).content
             headElem = @poemElem.at_xpath("tei:head[@n='#{m[1]}']/text()", TEI_NS)

             # Locate the <head> element to be linked
             # (If this <head> element hasn't been appended, append it)
             # @todo Refactor

             headElem = @poemElem.at_xpath("tei:head[@n='#{m[1]}']", TEI_NS)
             if not headElem

               # @todo Refactor
               # @textElem.at_xpath("tei:front", TEI_NS).add_child ptrElem
               frontElem = @textElem.at_xpath("tei:front", TEI_NS)
               if not frontElem

                 # @todo Refactor
                 frontElem = Nokogiri::XML::Node.new('front', @teiDocument)
                 @textElem.add_previous_sibling(frontElem)
               end
               
               # Add the new header elee
               # @todo Refactor
               headElem = Nokogiri::XML::Node.new('head', @teiDocument)
               frontElem.add_child(headElem)
             end

             authorText = headElem.content

             # In some cases, the author name is prepended with the string "By "; This should be removed
             m = /By (.+)/.match(authorText)

             authorText = m[1] if m
             authorElem = Nokogiri::XML::Node.new('author', @teiDocument)
       
             authorElem.content = authorText
             authorElem = parseNotaBeneToken('', '', authorElem)
       
             @headerElement.at_xpath('tei:fileDesc/tei:titleStmt', TEI_NS).add_child(authorElem)
             # else

             #  puts @teiDocument.to_xml
             #  raise NotImplementedError, "Could not resolve the author for #{authorText}"
             #end
           end
         end
       end
     end
   end

   def parseTOCFootNote(line)

     # Parse for the value of the "Table of contents title:" field
     m = /Table of contents title:«MDNM» (.+)/.match(line)
       
     if m and m[1].strip != '--'

       frontElem = Nokogiri::XML::Node.new('front', @teiDocument)
       headElem = Nokogiri::XML::Node.new('head', @teiDocument)

       headText = Nokogiri::XML::Text.new(m[1], @teiDocument)
       headElem.add_child headText
       frontElem.add_child(headElem)
       @textElem.add_previous_sibling(frontElem)

       # parseXMLTextNode requires access to the parent
       parseXMLTextNode headText
     end
   end

   def parseSicNote(targetElem, searchStr)

     str = ''

     text = stripNotaBeneTokens(searchStr)
     text = Regexp.escape(text)

     containsSearchStr = true if targetElem.content.match(/#{ text }/)

     elems = Nokogiri::XML::NodeSet.new(@teiDocument)
     targetElem.children.each do |child|

       # If the child node is a text node...
       if child.text?
                     
         m = child.content.match(/#{ text }/)
                    
         # If the text is found within the current text node...
         if m

           # If there are substrings prepended to, appended to, or surrounding the data, split strings
           strs = child.content.split(/(?=#{text})|(?<=#{text})/)

           # ...if the phrase occurs more than once, attempt to further split the line
           strs = child.content.split(/\s#{text}\s/) if strs.length > 3

           # If the phrase occurs more than once
           if strs.length > 3
             
             raise NotImplementedError.new("The phrase '#{text}' occurs more than once in a phrase: #{strs}")
           else

             # ...otherwise, create the <note type="sic"> element...
             e = Nokogiri::XML::Node.new('note', @teiDocument)
             e['type'] = 'sic'
             e.content = text

             if strs.length > 2

               if strs[2] == text

                 elems |= Nokogiri::XML::NodeSet.new(@teiDocument, [Nokogiri::XML::Text.new(strs[0], @teiDocument), Nokogiri::XML::Text.new(strs[1], @teiDocument), e])
               elsif strs[1] == text

                 elems |= Nokogiri::XML::NodeSet.new(@teiDocument, [Nokogiri::XML::Text.new(strs[0], @teiDocument), e, Nokogiri::XML::Text.new(strs[2], @teiDocument)])
               else

                 elems |= Nokogiri::XML::NodeSet.new(@teiDocument, [e, Nokogiri::XML::Text.new(strs[1], @teiDocument), Nokogiri::XML::Text.new(strs[2], @teiDocument)])
               end
             elsif strs.length > 1

               if strs[1] == text

                 elems |= Nokogiri::XML::NodeSet.new(@teiDocument, [Nokogiri::XML::Text.new(strs[0], @teiDocument), e])
               else
                 
                 elems |= Nokogiri::XML::NodeSet.new(@teiDocument, [e, Nokogiri::XML::Text.new(strs[1], @teiDocument)])
               end
             else

               elems |= Nokogiri::XML::NodeSet.new(@teiDocument, [e])
             end
           end
         else # Just add the text element

           elems |= Nokogiri::XML::NodeSet.new(@teiDocument, [child])
         end
       else # If this is not a text node, recurse until it is

         elems |= Nokogiri::XML::NodeSet.new(@teiDocument, [parseSicNote(child, searchStr)])
       end
     end
     
     #return elems
     targetElem.content = ''
     targetElem.add_child elems
     return targetElem
   end

   ##
   # This method parses the SPP document footnotes

   def parseFootNotes

     sicLineNumber = nil
     
     @footNotes.each_line do |line|
       
       line.chomp!

       parseAttributionFootNote(line)
       parseTOCFootNote(line)

       # $$«MDBO»Sic:«MDNM» 32 «MDUL»partiam«MDNM»   36 Os «MDUL»petrosum«MDNM»   40 sufferrers   42 fortnigt

       # Parse for the value of the "Sic" field
       #m = /Sic:«MDNM» (.+)/.match(line)
       m = /Sic:«MDNM»(.+)/.match(line)

       if m

         sicField = m[1]

         # (/(\d+\D+)(\d+.+)/).match[1] = ;
         # (/(\d+\D+)(\d+.+)/).match[2] = ;

         if sicField.match(/\[.+\]/)
           
           # .sub(/(\d+\D+)(\d)/, '\1;\2')
           
           sicField
             .strip
             .sub(/(\d+\D+)(?=\d)/,'\1 ')
             .sub(/, /,'')
             .split(/(?<=\])/)
             .each { |s|

             s.strip!

             # James: To be refactored
             if not s
               
               next
             end

             s.split(/(?= \d.+\[)/).each { |_s|

               # HN1 some data 01
               # 2 some data 02
               # 1 pleases [so 07S1]

               m = /(H?N?\d+ \D+)\d/.match(s)
               if not m
                 
                 s = _s
                 m = /(H?N?\d+ \D+)\d/.match(s)
               end
             
               s.strip!
               
               if not s

                 raise NotImplementedError.new "Could not parse the following \"sic\" comment \"#{sicField}\""
               end
             }
           }
         else

           if sicField.match(/   /)

             sicField.split(/(?= \d+ \w+)/).each do |s|

               s.strip!

               m = s.match(/(\d+) (.+)/)
               if m

                 lineNumber = m[1]

                 sicPhrase = m[2]

                 sicElem = Nokogiri::XML::Node.new('note', @teiDocument)
                 sicElem['type'] = 'sic'
                 sicElem.content = sicPhrase

                 targetElem = @textElem.at_xpath("//tei:l[@n='#{lineNumber}']", TEI_NS)

                 containsSearchStr = false

                 results = parseSicNote(targetElem, sicPhrase) if targetElem
               end
             end
           else

             # Refactor
             m = sicField.match(/(\d+) (.+)/)
             if m

               lineNumber = m[1]
               
               sicPhrase = m[2]

               sicElem = Nokogiri::XML::Node.new('note', @teiDocument)
               sicElem['type'] = 'sic'
               sicElem.content = sicPhrase

               targetElem = @textElem.at_xpath("//tei:l[@n='#{lineNumber}']", TEI_NS)

               results = parseSicNote(targetElem, sicPhrase) if targetElem
             end
           end
         end
       end
     end
     
     return @teiDocument
   end

   # «MDBO»Sic:«MDNM» 32 «MDUL»partiam«MDNM»   36 Os «MDUL»petrosum«MDNM»   40 sufferrers   42 fortnigt

   def parseSicRecord(sicRecord, lineNumber)

     # Assuming that the "Sic" field value does not contain the substring...
     if not /\-\-/.match(sicRecord.strip)
       
       # ... attempt extract the header number from the value...
       m = sicRecord.match(/^HN(\d+) (.*)/)
       
       begin
         
         # ...and if there is a header number specified...
         if m
             
           headNumber = m[1]
           sicPhrase = m[2]
         else # ...and if there isn't a header number specified...

           # ...attempt to extract the line number from the value...
           m = sicRecord.match(/^(\d+)n? (.*)/)
           if m
         
             lineNumber = m[1]
             sicPhrase = m[2]
           else
             
             # ...if this attempt failed, attempt to extract the range of line numbers specified...
             m = sicRecord.match(/^(\d+)\-(\d+) *(.*)?/)

             # ...and if there has been a new line number specified...
             if m

               # ...store the new line number...
               lineNumber = m[1]

               # ...the "sic" phrase itself...
               sicPhrase = m[3]

               # ...and the range of line numbers.
               lineNumbers = Range.new lineNumber, m[2]
             elsif not lineNumber

               raise NotImplementedError.new "Line numbers could not be extracted from the \"sic\" comment"
             else
               
               sicPhrase = sicRecord
             end
           end
         end
       rescue => ex # Handle all errors by raising a NotImplementedError

         raise NotImplementedError.new "Could not parse the following \"sic\" comment \"#{sicRecord}\": #{ex.message}: #{ex.backtrace.join "\n"}"
       end

       e = Nokogiri::XML::Node.new('note', @teiDocument)
       m = /«MD.{2}»/.match(sicPhrase)
       sicPhrase.gsub!(/«MD.{2}»/,'')
       lineElem = nil
       
       if m
       
         # Works for <hi>partiam usu</hi> where sicPhrase 'partiam'
         # Does not work for <hi>petrosum</hi> where sicPhrase is 'Os petrosum'
         #lineElem = @poemElem.at_xpath('tei:lg/tei:l[@n='+lineNumber+']/tei:hi[contains(text(), \''+sicPhrase+'\')]', TEI_NS)

         if headNumber
           
           lineElems = @poemElem.xpath('tei:head[@n='+headNumber+']/tei:hi', TEI_NS)
         else

           #lineElems = @poemElem.xpath('tei:lg/tei:l[@n='+lineNumber+']/tei:hi', TEI_NS)
           lineElems = @poemElem.xpath('tei:' + @blockElemName + '/tei:' + @lineElemName + '[@n=' + lineNumber + ']/tei:hi', TEI_NS)
         end

         lineElems.each do |node|
           
           if node.content.include? sicPhrase or sicPhrase.include? node.content
             
             lineElem = node
           end
         end
       else
         
         if headNumber
           
           lineElem = @poemElem.at_xpath('tei:head[@n='+headNumber+']', TEI_NS)
         else
           
           lineElem = @poemElem.at_xpath('tei:'+@blockElemName+'/tei:'+@lineElemName+'[@n='+lineNumber+']', TEI_NS)
         end
       end
       
       if not lineElem

         # If the line element exists but does not contain any of the "sic" field value substrings, use the line element alone
         lineElem = @poemElem.at_xpath('tei:'+@blockElemName+'/tei:'+@lineElemName+'[@n=1]', TEI_NS)

         if not lineElem
         
           raise NotImplementedError.new "Failed to locate string: "+sicPhrase+" within "+@poemElem.at_xpath('tei:'+@blockElemName+'/tei:'+@lineElemName+'[@n=1]', TEI_NS).content
         end
       end
         
       #lineElem = @poemElem.at_xpath('tei:lg/tei:l[@n='+m[1]+']', TEI_NS)
       
       line = lineElem.content       
       lines = nil
       
       if line.include? sicPhrase
         
         lines = line.split(sicPhrase)
       end
       
       sicElem = Nokogiri::XML::Node.new('note', @teiDocument)
       sicElem['type']='sic'
       sicElem.content = sicPhrase
       
       if lines and lines[0]
         
         lineElem.add_child(Nokogiri::XML::Text.new(lines[0], @teiDocument))
       end
       
       # Notes can be children of <hi> elements.  Please see http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-note.html
       lineElem.add_child(sicElem)
       
       if lines and lines.size > 1
         
         lineElem.add_child(Nokogiri::XML::Text.new(' '+lines[lines[1] == '' ? 2 : 1], @teiDocument))
       end
     end
     
     return lineNumber
   end

   def getCollection(poemID)
     
     SPP_COLLECTIONS.each_key do |key|
       
       if SPP_COLLECTIONS[key].include? poemID
         return key
       end
     end
   end

   def transform(xslFilePath)

     tmpFilePath = "/tmp/tmp_spp_#{Time.now.to_i}.xml"

     File.open(tmpFilePath, 'w') {|f| f.write(@teiDocument.to_xml) }
     
     return Nokogiri::XSLT(File.open(xslFilePath, 'rb')).transform(Nokogiri.XML(File.open(tmpFilePath, 'rb')))
   end

   def getHtml5()

     return transform '/usr/share/stylesheets/tei/html5/tei.xsl'
   end

   def getXhtml()

     #return transform '/usr/share/stylesheets/tei/xhtml2/tei.xsl'
     #return transform 'xslt/spp/xhtml.xsl'
     return transform "#{File.dirname(__FILE__)}/xslt/xhtml.xsl"
   end

   def getHtml()

     return transform 'xslt/xhtml.xsl'
   end
   
   def getTeiBp()
     
     return transform '/usr/share/stylesheets/teibp/content/teibp.xsl'
   end
   
   def validate(xsdUri)
     
     # RelaxNG
     schemaDoc = Nokogiri::XML::RelaxNG(open(xsdUri))
     schemaDoc.validate(@teiDocument)
   end
 end

 class TeiDocumentSet
   
   TEI_CORPUS = 0
   TEI_BOOKS = 1
   TEI_POEMS = 2

   def initialize(docs)

     @teiDocuments = docs
   end

   # nDepthElementsSetComparator

   def lineDeepElementSetComparator()

     return lambda do |set|

       indexElements = {}

       uLastIndex = 0

       # [ stanza1, stanza2, stanza3, stanza4..., stanza1... ]
       i=0

       while(i < set.length)

         if(indexElements.values.length == 0 and set[i].children.select {|child| child.is_a?(Nokogiri::XML::Element) and not child.children.empty? }.empty?)
           
           indexElements[indexElements.values.length] = Nokogiri::XML::NodeSet.new(set.document, [set[i]])
         elsif((not set[i]['n']) or (set[i].xpath('(*)[last()]', TEI_NS).empty?)) # If this element does not have an index or children...

           # Refactor
           # If this element is not synchronized with the iteration
           if(set[i]['n'] and set[i]['n'].to_i == indexElements.values.length)

             # If this index does not exist within the hash...
             if not indexElements.include?(indexElements.values.length)
             
               indexElements[indexElements.values.length] = Nokogiri::XML::NodeSet.new(set.document, [set[i]])
             else
             
               # Add the element to the set of XML nodes
               indexElements[(indexElements.values.length)].push(set[i])
             end
           elsif(not set[i]['n']) # Refactor
             
             if not indexElements.include?(indexElements.values.length)
             
               indexElements[indexElements.values.length] = Nokogiri::XML::NodeSet.new(set.document, [set[i]])
             else

               indexElements[(indexElements.values.length)].push(set[i])
             end
           end
         else

           # If an element with this index has not been inserted into the hash yet, insert it the first element
           if(not indexElements.include?(set[i]['n']))

             indexElements[set[i]['n']] = Nokogiri::XML::NodeSet.new(set.document, [set[i]])
           else

             # If an element with this index has been inserted into the hash, append its children to the only element (exclusive to the first TEI)
             #indexElements[e['n']].add_child(e.children())

             # If an element with this index has been inserted into the hash, append its children to the only element (exclusive to the first TEI), as well as the children of other successive elements

             # TO DO: Implement for children not containing an index

             # Determine the greatest index of the elements within the children of this element
             lastChildElementV = set[i].at_xpath('*[last()]', TEI_NS)

             if not lastChildElementV['n']

               raise NotImplementedException.new
             end

             # Determine the greatest index of the elements within the children of the indexed element
             lastChildElementU = indexElements[set[i]['n']].at_xpath('*[last()]', TEI_NS)

             if not lastChildElementU['n']

               raise NotImplementedException.new
             end

             # If the length of the indexed elements exceeds that of the stanza being copied...
             if lastChildElementU['n'].to_i > lastChildElementV['n'].to_i

               # ...append all of the children from the stanza being copied...
               if(lastChildElementU.xpath('*', TEI_NS).empty?)

                 indexElements[set[i]['n']].first.add_child(set[i])
               else

                 indexElements[set[i]['n']].first.add_child(set[i].children)
               end

               j=i
               i+=1
               # ...iterate to the next element in the set...
               lastChildElementN = set[i].at_xpath('(*)[last()]', TEI_NS)

               # ...and copy the children from all neighboring elements until the index is reached.
               while lastChildElementN and lastChildElementU['n'] > lastChildElementN['n']

                 # ...append all of the children from the stanza being copied...
                 if(lastChildElementN.xpath('*', TEI_NS).empty?)

                   indexElements[set[j]['n']].first.add_child(set[i])
                 else

                   indexElements[set[j]['n']].first.add_child(set[i].children)
                 end

                 i+=1
                 if(not set[i])

                   break
                 end

                 # ...iterate to the next element in the set...
                 lastChildElementN = set[i].at_xpath('(*)[last()]', TEI_NS)
               end

               if(not set[i])

                 next
               end
               # Copy all remaining child elements within the adjacent parent element
               childElementsSubsetN = set[i].xpath("*[number(@n) <= #{lastChildElementU['n']}]", TEI_NS)

               if not childElementsSubsetN.empty?

                 indexElements[set[j]['n']].first.add_child(childElementsSubsetN)

                 if not indexElements.include?(j + 1)

                   newElement = Nokogiri::XML::Node.new(set[j].name, set.document)
                   newElement['n'] = set[j + 1]['n']
                   newElement['type'] = set[j]['type']
                   newElement.add_child(set[i].xpath("*[number(@n) > #{lastChildElementU['n']}]", TEI_NS))

                   indexElements[set[j + 1]['n']] = Nokogiri::XML::NodeSet.new(set.document, [newElement])
                 elsif indexElements[set[j + 1]['n']].at_xpath('*[@n]', TEI_NS).empty?

                   raise NotImplementedError.new
                 else

                   indexElements[set[j + 1]['n']].first.add_child(set[i].xpath("*[number(@n) > #{lastChildElementU['n']}]", TEI_NS))
                 end
               end

               i = j
             elsif lastChildElementU['n'] < lastChildElementV['n'] # If the length of the indexed elements is less than that of the stanza being copied...

               # Copy all child elements within the adjacent parent element to the indexed primary element
               childElementsSubsetV = set[i].xpath("(*)[number(@n) <= #{lastChildElementU['n']}]", TEI_NS)
               indexElements[set[i]['n']].first.add_child(childElementsSubsetV)
               
               j=i
               j+=1

               # ...iterate to the next element in the set...
               lastChildElementN = set[j].at_xpath('(*)[last()]', TEI_NS)

               while lastChildElementN['n'].to_i < lastChildElementV['n'].to_i

                 # Insert child elements
                 childElementsSubsetV = set[i].xpath("(*)[number(@n) <= #{lastChildElementN['n']}]", TEI_NS)

                 # If the element has not yet been indexed...
                 if not indexElements.include?(set[j]['n'])
                   
                   newElement = Nokogiri::XML::Node.new(set[j].name, set.document)
                   newElement['n'] = set[j]['n']
                   newElement['type'] = set[j]['type']
                   newElement.add_child(childElementsSubsetV)
                   indexElements[set[j]['n']] = Nokogiri::XML::NodeSet.new(set.document, [newElement])
                 else

                   indexElements[set[j]['n']].first.add_child(childElementsSubsetV)
                 end

                 j+=1

                 if not set[j]

                   break
                 end
                 lastChildElementN = set[j].at_xpath('(*)[last()]', TEI_NS)
               end
             else

               if(set[i].children.select {|child| child.is_a?(Nokogiri::XML::Element) and not child.children.empty? }.empty?)
                 
                 indexElements[set[i]['n']].first.add_child(set[i])
               else

                 indexElements[set[i]['n']].first.add_child(set[i].children)
               end
             end
           end
         end

         i+=1
       end

       results = Nokogiri::XML::NodeSet.new(set.document)

       elementSet = {}
       indexElements.values.reduce(:|).each do |e|
         
         if not e['n']

           if elementSet.length == 0
             
             elementSet[0] = Nokogiri::XML::NodeSet.new(set.document, [e])
           else
             
             elementSet[ (10*elementSet.length)**-1 ] = Nokogiri::XML::NodeSet.new(set.document, [e])
           end
         else

           # Are there child elements to be sorted?
           if not e.xpath('*', TEI_NS).select {|node| node.is_a? Nokogiri::XML::Element}.empty?

             childElementSet = {}
             e.children.each do |child|

               if not childElementSet.include?(child['n'])

                 childElementSet[child['n']] = Nokogiri::XML::NodeSet.new(set.document, [child])
               else

                 childElementSet[child['n']].push(child)
               end
             end

             e.content = ''
             e.add_child(childElementSet.values.reduce(:|))

             elementSubset = Nokogiri::XML::NodeSet.new(set.document, [e])
           else

             elementSubset = Nokogiri::XML::NodeSet.new(set.document, [e])
           end

           if(not elementSet.include?(e['n']))
           
             elementSet[e['n']] = elementSubset
           else
             
             elementSet[e['n']] |= elementSubset
           end
         end
       end

       return elementSet.each_value.reduce(:|)
     end
   end

   def stanzaDeepElementSetComparator()

     return lambda do |set|

       indexElements = {}

       # Include the first element as the sole parent
       set.each do |e|

         if not e['n']

           if indexElements.values.length == 0

             indexElements[1] = e
           else

             # Refactor
             indexElements[(indexElements.values.length) + (10 * (indexElements.values.length))**-1] = e
           end
         else

           if(not indexElements.include?(e['n']))
             
             indexElements[e['n']] = e
           else

             indexElements[e['n']].add_child(e.children())
           end
         end
       end

       results = Nokogiri::XML::NodeSet.new(set.document)
       indexElements.values.each do |e|

         _indexElements = {}

         e.children.each do |child|

           # Handling for child elements with or without indices
           if not child['n']

             if _indexElements.values.length == 0

               _indexElements[1] = Nokogiri::XML::NodeSet.new(set.document, [child])

             elsif not _indexElements.include?( _indexElements.values.length)

               _indexElements[(_indexElements.values.length)] = Nokogiri::XML::NodeSet.new(set.document, [child])
             else

               _indexElements[(_indexElements.values.length)].push(child)
             end
           else

             if(not _indexElements.include?(child['n']))

               _indexElements[child['n']] = Nokogiri::XML::NodeSet.new(set.document, [child])
             else

               _indexElements[child['n']].push(child)
             end
           end
         end
         
         e.content = ''

         e.add_child(_indexElements.each_value.reduce(:|))

         results.push(e)
       end

       return results
     end
   end

   def deeplyIntegrate()

     return integrate(lineDeepElementSetComparator)
   end

   def elementSetComparator()

     return lambda do |set|

       results = Nokogiri::XML::NodeSet.new(set.document)

       indexElements = {}

       set.each do |e|

         if(e['n'])

           if(not indexElements.include?(e['n']))
             
             indexElements[e['n']] = Nokogiri::XML::NodeSet.new(set.document, [e])
           else

             indexElements[e['n']].push(e)
           end
         end
       end

       indexElements.each_value do |subset|

         results |= subset
       end
       
       return results

       # return indexElements.each_value.reduce(:|)
     end
   end

   def orderedIntegrate()

     return integrate(elementSetComparator)
   end

   # By default, this is a "union" operation (i. e. all elements occupy the same Poem/Letter entity)
   def integrate(operation = lambda {|e| e})

     doc = Nokogiri::XML(TEI_P5_DOC, &:noblanks)

     titles = Nokogiri::XML::NodeSet.new(doc)
     @teiDocuments.each do |teiDoc|

       titles |= teiDoc.xpath('tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title', TEI_NS)
       #titles |= titleStmtElem.xpath('tei:title', TEI_NS)
     end

     authors = Nokogiri::XML::NodeSet.new(doc)
     @teiDocuments.each do |teiDoc|

       authors |= teiDoc.xpath('tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author', TEI_NS)
       #authors |= titleStmtElem.xpath('tei:author', TEI_NS)
     end

     headers = Nokogiri::XML::NodeSet.new(doc)
     @teiDocuments.each do |teiDoc|

       headers |= teiDoc.xpath('tei:TEI/tei:text/tei:body/tei:div/tei:div/tei:head', TEI_NS)
     end

     stanzas = Nokogiri::XML::NodeSet.new(doc)

     @teiDocuments.each do |teiDoc|

       stanzas |= teiDoc.at_xpath('tei:TEI/tei:text/tei:body/tei:div/tei:div', TEI_NS).xpath('tei:lg | tei:div', TEI_NS)
     end

     #titleStmtElem = doc.at_xpath('tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt')
     #titleStmtElem.add_child([titles, authors].map { |elemSet| operation.call(elemSet) }.reduce(:|))
     #doc.at_xpath('tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt', TEI_NS).add_child([titles, authors].map { |elemSet| operation.call(elemSet) }.reduce(:|))
     doc.at_xpath('tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:sponsor', TEI_NS).add_previous_sibling([titles].map { |elemSet| operation.call(elemSet) }.reduce(:|))
     doc.at_xpath('tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:sponsor', TEI_NS).add_previous_sibling([authors].map { |elemSet| operation.call(elemSet) }.reduce(:|))

     poemElem = doc.at_xpath('tei:TEI/tei:text/tei:body/tei:div/tei:div', TEI_NS)

     # Refactor: We cannot always assume that this is going to be a poem
     poemElem['type'] = 'poem'
     poemElem.add_child([headers, stanzas].map { |elemSet| operation.call(elemSet) }.reduce(:|))
     #doc.at_xpath('tei:TEI/tei:text/tei:body/tei:div/tei:div', TEI_NS).add_child([headers, stanzas].map { |elemSet| operation.call(elemSet) }.reduce(:|))
     
     return doc
   end

   def concatenate(teiDocStructure = TEI_CORPUS)

     compositeDoc = Nokogiri::XML(TEI_P5_CORPUS_DOC, &:noblanks)

     if(teiDocStructure == TEI_BOOKS or teiDocStructure == TEI_POEMS)

       @teiDocuments.each do |teiDoc|

         docId = teiDoc.at_xpath('tei:TEI/tei:text/tei:body/tei:div[@type="book"]/tei:div/@n', TEI_NS)
         unless compositeDoc.at_xpath("tei:TEI/tei:text/tei:body/tei:div[@type='book']/tei:div[@n='#{docId}']", TEI_NS)

           if(teiDocStructure == TEI_POEMS)

             compositeDoc.at_xpath("tei:TEI/tei:text/tei:body/tei:div[@type='book']", TEI_NS).add_child(teiDoc.at_xpath('tei:TEI/tei:text/tei:body/tei:div[@type="book"]/tei:div', TEI_NS))
           else

             bookElement = compositeDoc.at_xpath("tei:TEI/tei:text/tei:body", TEI_NS).add_child(Nokogiri::XML::Node.new('div', compositeDoc))
             bookElement['type'] = 'book'

             compositeDoc.at_xpath("(tei:TEI/tei:text/tei:body/tei:div[@type='book'])[last()]", TEI_NS).add_child(teiDoc.at_xpath('tei:TEI/tei:text/tei:body/tei:div[@type="book"]/tei:div', TEI_NS))
           end
         end
       end
     else

       @teiDocuments.each do |teiDoc|

         compositeDoc.at_xpath('tei:teiCorpus/tei:teiHeader', TEI_NS).add_next_sibling(teiDoc.at_xpath('tei:TEI', TEI_NS))
       end
     end
     
     return compositeDoc
   end
 end

 class NotaBeneFileParser

   def initialize verbosity=1

     @verbose = verbosity
   end

   def parseFile filePath

     #begin

     # logger.debug "Parsing #{filePath}" if @verbose
     parser = TeiParser.new filePath
     parser.parse
     
     # logger.debug parser.teiDocument if @verbose > 1
     #rescue Exception => ex
       
       #puts"Warning: #{ex.message}"
     #end
   end

   def traverseDir dirPath
     
     Dir.entries(dirPath).each do |filePath|
       
       if not File.directory? "#{dirPath}#{filePath}"
         
         parseFile "#{dirPath}#{filePath}"
       else
         
         traverseDir "#{dirPath}#{filePath}" if not ['.', '..'].include? filePath
       end
     end
   end
 end

end