# -*- coding: utf-8 -*-
module SwiftPoemsProject

  # Constants

  # Types of documents
  POEM = 'poem'
  LETTER = 'letter'

  # Regular expression for extracting poem ID's
#  POEM_ID_PATTERN = /[0-9A-Z\!\-]{8}\s{3}\d+\s/

  DECORATOR_PATTERN = /«MD[SUNMD]{2}»\*(«MDNM»)?/

  # Nota Bene toke maps
  NB_TERNARY_TOKEN_TEI_MAP = {

    '«MDRV»' => {

      :secondary => {

#        '«MDUL»' => { 'hi' => { 'rend' => 'underline' } },
        '«MDSD»' => { 'hi' => { 'rend' => 'SMALL-CAPS' } }
      },

      :terminal => { '«MDNM»' => { 'hi' => { 'rend' => 'display-initial' } }
        
      }
    },

    '«MDBU»' => {

      :secondary => { '«MDUL»' => { 'hi' => { 'rend' => 'black-letter' } }

      },

      :terminal => { '«MDNM»' => { 'hi' => { 'rend' => 'black-letter' } }
        
      }
    },

    '«MDSD»' => {

      :secondary => {

        '«MDUL»' => { 'hi' => { 'rend' => 'underline'  } }
      },
      :terminal => {

        '«MDNM»' => { 'hi' => { 'rend' => 'SMALL-CAPS' } }
      },
    },

    '«MDUL»' => {

      :secondary => {
        '«FC»' => { 'hi' => { 'rend' => 'underline' } },
        '«MDBO»' => { 'hi' => { 'rend' => 'underline' } },
        '«MDSD»' => { 'hi' => { 'rend' => 'SMALL-CAPS' } },
      },

      :terminal => { '«MDNM»' => { 'head' => { } } }
    },

    
    '«MDSU»' => {

      :secondary => {

        '«MDBU»' => { 'hi' => { 'rend' => 'sup' } },
        '«MDUL»' => { 'hi' => { 'rend' => 'underline' } }
      },

      :terminal => { '«MDNM»' => { 'hi' => { 'rend' => 'black-letter' } }
        
      }
    },
  }

  NB_MARKUP_TEI_MAP = {

    '«DECORATOR»' => {
        
      '«/DECORATOR»' => { 'unclear' => { 'reason' => 'illegible' } }
    },
      
    '«MDUL»' => {
        
      '«MDNM»' => { 'hi' => { 'rend' => 'underline' } },
      '«MDBO»' => { 'hi' => { 'rend' => 'underline' } },
      '«MDUL»' => { 'hi' => { 'rend' => 'underline' } },
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
      '.»' => { 'note' => { 'place' => 'foot' } },
      '──────»' => { 'note' => { 'place' => 'foot' } }
    },

    # Additional footnotes
    '«FN1' => {
      
      '»' => { 'note' => { 'place' => 'foot' } },
      '.»' => { 'note' => { 'place' => 'foot' } }
    },

    # Additional footnotes
    '«FN1«MDNM»' => {
        
      '»' => { 'note' => { 'place' => 'foot' } }
    },

    # For deltas
    # The begin-center (FC, FL) delta
#    '«FC»' => {
      
#      '«MDNM»' => { 'note' => { 'rend' => "align(center)" } }
#    },

    # The end-of-center (FL, FL) delta
#    '«FL»' => {
      
#      '«MDNM»' => { 'note' => { 'rend' => "flush left" } },
#    },
    
    # The flush right (FR, FL) delta
#    '«FR»' => {
      
#      '«FL»' => { 'note' => { 'rend' => "flush right" } }
#    },
    
    # <gap>
    'om' => {

      '.' => { 'gap' => {} }
    },

  }

  # This hash is for Nota Bene tokens which encompass a single line (i. e. they are terminated by a newline character rather than another token)
  NB_SINGLE_TOKEN_TEI_MAP = {

    # The flush right (LD) delta
    '«LD»' => {
      
      'note' => { 'rend' => "flush right" }
    },
    '«LD »' => {
      
      'note' => { 'rend' => "flush right" }
    },
    
    # Footnotes encompassing an entire line
    '«FN1·»' => {
      
      'note' => { 'place' => 'foot' }
    },

    '«UNCLEAR»' => {

      'unclear' => { 'reason' => 'illegible' }
    },

    '«FL»' => {

      'note' => { 'rend' => "flush left" }
    },

    '«FC»' => {
      
      'note' => { 'rend' => "align(center)" }
    },

    # The flush right (FR, FL) delta
    '«FR»' => {
      
      'note' => { 'rend' => "flush right" }
    },

    'om.' => {
      'gap' => {}
    },

    '^' => {
      'lb' => {}
    },
  }

  NB_DELTA_FLUSH_TEI_MAP = {

    '«LD»' => {
      
      'rend' => "flush right"
    },

    '«FL»' => {

      'rend' => "flush left"
    },

    '«FC»' => {
      
      'rend' => "align(center)"
    },

    '«FR»' => {
      
      'rend' => "flush right"
    },
  }

  NB_DELTA_ATTRIB_TEI_MAP = {

    '«LD»' => {
      
      'rend' => "flush right"
    },

    '«FL»' => {

      'rend' => "flush left"
    },

    '«FC»' => {
      
      'rend' => "align(center)"
    },

    '«FR»' => {
      
      'rend' => "flush right"
    },
  }

  NB_CHAR_TOKEN_MAP = {
      
    /\\ae\\/ => 'æ',
    /\\AE\\/ => 'Æ',
    /\\oe\\/ => 'œ',
    /\\OE\\/ => 'Œ',
    /``/ => '“',
    /''/ => '”',
#    /(?<!«MDNM»|«FN1)·/ => ' ',
    /─ / => '─'    
  }

  # The XML TEI namespace
  TEI_NS = {'tei' => 'http://www.tei-c.org/ns/1.0'}

  POEM_ID_PATTERN = /^[0-9A-Z\!\-]{8}\s+/

  # This models the functionality unique to Swift Poems Project Transcripts (i. e. Nota Bene Documents)
  # All tokenization is to be refactored here
  class Transcript

    attr_reader :tei, :nota_bene, :id

    # Legacy attributes
    attr_reader :poemID, :teiDocument, :documentTokens, :headerElement, :poemElem, :workType
    attr_accessor :headnote_open, :footnote_index, :headnote_opened_index

    def initialize(nota_bene)

      @nota_bene = nota_bene
      @tei = TEI::Document.new

      lines = @nota_bene.content.split(/\$\$\r?\n\S{8}?\s{3}/)

      # Parsing the header
      # @todo Refactor the exception if a header, body, and footer isn't present
      if lines.length != 2
        raise NotImplementedError.new "Could not parse the structure of the Nota Bene transcript #{@nota_bene.file_path}: doesn't have a header"
      end

      @header = Header.new self, lines.shift

      lines = lines.last.split(/##\s*\r?\n/)

      # Parsing the heading
      # @todo Refactor the exception
      if lines.length != 2
        raise NotImplementedError.new "Could not parse the structure of the Nota Bene transcript #{@nota_bene.file_path}: doesn't have a heading"
      end

      # Legacy attributes for the state of the transcript
      # @todo Refactor
      @headnote_open = false
      @footnote_index = 0
      @teiDocument = @tei.teiDocument
      @documentTokens = []
      @headerElement = @tei.headerElement
      @poemElem = @tei.poemElem
      # @termToken = nil
      # @poem = @body.poem

      # Initialize the legacy attributes
      @id = parse_id
      @poemID = @id

      # This deprecates "titleAndHeadnote"
      @heading = Heading.new self, lines.shift
      if @heading.content.match(/letter/i)
        @workType = LETTER
      else
        # By default, all documents are poems
        @workType = POEM
      end

      # Parsing the body and footer

      lines = lines.last.split(/%%\r?\n?/)
      # @todo Refactor the exception
      if lines.length != 2
        raise NotImplementedError.new "Could not parse the structure of the Nota Bene transcript #{@nota_bene.file_path}: doesn't have a body and footer"
      end

      @body = Body.new self, lines.shift

      @footer = Footer.new self, lines.pop
    end

    # Legacy functionality
    # @todo Refactor
    def parse_id

      # Extract the poem ID
      m = /(.?\d\d\d\-?[0-9A-Z\!\-]{4,5})   /.match(@nota_bene.content)

      # Searching for alternate patterns
      # Y46B45L5
      # Y09C27L3
      m = /([0-9A-Z\!\-]{8})   /.match(@nota_bene.content) if not m

      # «MDBO»Filename:«MDNM» 920-0201
      m = /«MDBO»Filename:«MDNM» ([0-9A-Z\!\-]{7,8}[#\$@]?)/.match(@nota_bene.content) if not m
      m = /«MDBO»Filename:«MDNM» ([0-9A-Z\!\-#\$]{7,8}[#\$@]?)/.match(@nota_bene.content) if not m

      raise NoteBeneFormatException.new "#{@filePath} features an ID of an unsupported format" unless m

      m[1]
    end

    def to_html(xslt_file_path = 'xslt/tei_xhtml.xslt')
      xslt = Nokogiri::XSLT(File.read(xslt_file_path))
      xslt.transform(@tei.document)
    end
  end

  class Element
    
    attr_reader :content, :transcript

    def initialize(transcript, content)
      @transcript = transcript
      @content = content
    end
  end

  # Class for modeling the "headers" within SPP Transcripts
  # (These are blocks of text which contain SPP Transcript metadata, formatted in a manner which is unique to the project)
  class Header < Element

    def initialize(transcript, content)
      super(transcript,content)

      @content.each_line do |line|
        
        line.chomp!
        
        if /& dates?:/.match(line)
          
          # Extracting the <name> values from the parse "Transcriber & date" value
          if /Transcriber & date:/.match(line)
            
            respStmtElem = Nokogiri::XML::Node.new('respStmt', @transcript.tei.teiDocument)
            nameElem = Nokogiri::XML::Node.new('name', @transcript.tei.teiDocument)
            
            transcriber_m = /Transcriber & date:.?«MDNM.?» (.+) /.match(line)
            
            if transcriber_m
              name = transcriber_m[1]
              nameElem['key'] = name
              respStmtElem.add_child(nameElem)
            else
              raise NotImplementedError.new "Failed to parse the transcribers from #{line}"
            end
            
            respElem = Nokogiri::XML::Node.new('resp', @transcript.tei.teiDocument)
            respElem.content = 'transcription'
            respStmtElem.add_child(respElem)
            
            @transcript.tei.headerElement.at_xpath('tei:fileDesc/tei:titleStmt', TEI_NS).add_child(respStmtElem)
          elsif /Proofed by & dates?:/.match(line)
            
            respStmtElem = Nokogiri::XML::Node.new('respStmt', @transcript.tei.teiDocument)
            
            nameElem = Nokogiri::XML::Node.new('name', @transcript.tei.teiDocument)
            
            # This handles lines formatted in the following manner:
            # Proofed by & dates:«MDNM» √'d JW 20JE07 agt 07H1; TNiese 25JA11
            # Note that there may be more than one name
            names = /Proofed by & dates:.?«MDNM.?» (.+)/
              .match( "Proofed by & dates:«MDNM» √'d JW 20JE07 agt 07H1; TNiese 25JA11" )[1]
              .sub(/√'d /, '')
              .split(';')
              .each { |s| s.strip! }
            
            names.each do |name|
              
              nameElem['key'] = name
              
              respElem = Nokogiri::XML::Node.new('resp', @transcript.tei.teiDocument)
              respElem.content = 'proof corrected'
              
              respStmtElem.add_child(respElem)
              respStmtElem.add_child(nameElem)
            end
            
            @transcript.tei.headerElement.at_xpath('tei:fileDesc/tei:titleStmt', TEI_NS).add_child(respStmtElem)
          elsif /Scanned by & date\:/.match(line)
            
            # This handles lines formatted in the following manner:
            # «MDBO»Scanned by & date:«MDNM» AGendler 22JE04
            respStmtElem = Nokogiri::XML::Node.new('respStmt', @transcript.tei.teiDocument)
            
            nameElem = Nokogiri::XML::Node.new('name', @transcript.tei.teiDocument)
            
            scanner_m = /Scanned by & date:«MDNM» (.+)/.match(line)
            
            if scanner_m
              
              name = scanner_m[1]
              nameElem['key'] = name
              respStmtElem.add_child(nameElem)
            end
            
            respElem = Nokogiri::XML::Node.new('resp', @transcript.tei.teiDocument)
            respElem.content = 'scanning'
            respStmtElem.add_child(respElem)
          elsif /File prepared by & date\:/.match(line)

            # This handles lines formatted in the following manner:
            # «MDBO»File prepared by & date:«MDNM» AGendler 22JE04
            respStmtElem = Nokogiri::XML::Node.new('respStmt', @transcript.tei.teiDocument)
            
            nameElem = Nokogiri::XML::Node.new('name', @transcript.tei.teiDocument)
            
            file_prepared_m = /File prepared by & date:«MDNM» (.+)/.match(line)
            
            if file_prepared_m
              
              name = file_prepared_m[1]
              nameElem['key'] = name
              respStmtElem.add_child(nameElem)
            end
            
            respElem = Nokogiri::XML::Node.new('resp', @transcript.tei.teiDocument)
            respElem.content = 'File prepared by'
            respStmtElem.add_child(respElem)          
          else            
            raise NotImplementedError, "Failed to parse the header value #{line}"
          end
        end
      end
    end
  end

  class Heading < Element

    # Legacy attributes
    attr_reader :teiDocument, :documentTokens, :headerElement

    # Parse the title and headnotes
    def initialize(transcript, content)
      super(transcript,content)

      # Legacy attributes
      @teiDocument = @transcript.teiDocument
      @documentTokens = @transcript.documentTokens
      @headerElement = @transcript.headerElement

      # Single parser instance must be utilized for multiple lines
      # @todo Refactor and restructure the parsing process
      headnote_parser = NotaBeneHeadnoteParser.new @transcript, @transcript.poemID, @content, nil, { :footnote_index => @transcript.footnote_index }

      # For each line containing the title and head-note fields...

      # Split the content on the first occurrence of the sequence "HN1"

      lines = @content.split(/.(?=HN1)/)
      if lines.length != 2
        
        # Handling for cases in which the headnotes aren't delimited using the "HN" sequence
        # Please see SPP-606
        lines = [ @content.split(/\n/)[0], @content.split(/\n/)[1..-1].join("\n") ]
      end

      title_content = lines.shift
      headnotes_content = lines.shift

      titles = TitleSet.new(self, @content, @transcript.headerElement, @transcript.poemID, { :footnote_index => @transcript.footnote_index })
      title_content.each_line do |line|        

        line.chomp!

        # ...remove the poem ID
        # @todo This should be refactored into <tei:title>
        line = line.sub(POEM_ID_PATTERN, '')

        line.strip!
        
        # ...continue to the next line if the line is empty or simply consists of the string "--"
        if line == '' or line == '--'
          next
        end

        tokens = @transcript.nota_bene.tokenize_titles(line)

        # As there exists no actual terminating character for titles, the index within the array must be used in order to generate the note
        tokens[0..-2].each do |token|
          titles.push token
        end

        titles.close tokens.last

        @transcript.footnote_index = titles.footnote_index
      end
        
      # Omit lines containing HN and -- for Headnote values
      # (These values do not map to any Element within a given TEI schema
        
      headnotes_content.each_line do |line|

        # ...remove the poem ID
        # @todo This should be refactored into <tei:title>
        line = line.sub(POEM_ID_PATTERN, '')
        
        headnote_parser.footnote_index = @transcript.footnote_index
          
        # Work-around
        # @todo Refactor
        @transcript.headnote_open = true

        headnote_parser.parse line
        @transcript.footnote_index = headnote_parser.footnote_index
      end
    end
  end
  
  # For Titles within the Swift Poems Project
  class TitleSet < Element

    attr_reader :sponsor, :elem, :opened_tags, :footnote_index, :document, :poem    

    def initialize(heading, content, element, poem_id, options = {})
      super(heading.transcript,content)

      @element = element

      # Legacy attribute
      @poem = content

      @poem_id = poem_id

      # Legacy attribute
      @id = @poem_id

      @document = @element.document
      @sponsor = @element.at_xpath('tei:fileDesc/tei:titleStmt/tei:sponsor', TEI_NS)
      @opened_tags = []

      @footnote_index = options[:footnote_index] || 1
        
      @titles = [ SwiftPoemsProject::Title.new(self, @id, { :footnote_index => @footnote_index }) ]
    end

    # Syntactic sugar
    # @todo Refactor
    def length
      @titles.length
    end

    # Syntactic sugar
    # @todo Refactor
    def last
      @titles.last
    end

    # This is likely deprecated and should be removed
    def pushTitle
        
      last_title = @titles.last

      # Add additional tokens
      @sponsor.add_previous_sibling @titles.last.elem

      @footnote_index = @titles.last.footnote_index

      @titles << SwiftPoemsProject::Title.new(self, @id, { :footnote_index => @titles.last.footnote_index })
      @titles.last.has_opened_tag = last_title.has_opened_tag

      if @titles.last.has_opened_tag

        @opened_tags.unshift last_title.current_leaf

        if not last_title.tokens.empty?
          
          @titles.last.current_leaf = @titles.last.elem.add_child Nokogiri::XML::Node.new last_title.tokens.last, @document
        else

          @titles.last.current_leaf = @titles.last.elem.add_child Nokogiri::XML::Node.new last_title.elem.children.last.name, @document
        end
      end
    end

    def push(token)
      # All lines of the title *must* be inserted into a single <title> Element
      @titles.last.push token
    end

    def close(token)

      token = token.sub /\r/, ''
      
      @titles.last.push token
      pushTitle
    end
  end
  
  class Body < Element

    # Parse the title and headnotes
    def initialize(transcript, content)
      super(transcript,content)

      # Set the identifier
      @transcript.tei.poemElement['n'] = @transcript.poemID

      # @poem = Poem.new(@content, @transcript.poemID, @transcript.workType, @transcript.tei.poemElem, @transcript.footnote_index)

      # Legacy
      # @todo Refactor so that the above becomes valid
      normal_content = SwiftPoemsProject::Poem.normalize(@content)
      @poem = SwiftPoemsProject::Poem.new(@transcript, normal_content, @transcript.poemID, @transcript.workType, @transcript.tei.poemElem, @transcript.footnote_index)
      @poem.parse
    end
  end
  
  class Footer < Element
  end

  module NotaBene

    class Document

      attr_reader :content, :tokens, :file_path

      def initialize(file_path)

        @file_path = file_path

        # Legacy attribute
        @filePath = @file_path

        # Read the file and convert the CP437 encoding into UTF-8
        @content = File.read(@filePath, :encoding => 'cp437:utf-8')

        # The tokens should be related to a single document
        @tokens = []
        @termToken = nil
      end

      def tokenize
        
        # This splits for each Nota Bene mode code
        @tokens = @content.split /(?=«)|(?=[\.─\\a-z]»)|(?<=«FN1·)|(?<=»)|(?=om\.)|(?<=om\.)|(?=\\)|(?<=\\)|(?=_)|(?<=_)|(?=\|)|(?<=\|)|\n/
      end

      def tokenize_titles(content)
        content.split /(?=«)|(?=\.»)|(?<=«FN1·)|(?<=»)|(?=\s\|)|(?=_\|)|(?<=_\|)/
      end
    end
  end

  module TEI

    # The essential elements of the TEI document
    # This assumes that all poems belong to a single corpus (a safe assumption at this point, but not safe for the duration of the project!)
    # It may become necessary to structure individual 
    
    # The entire document is within the English language
    # http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ST.html#STGAla

  TEI_P5_MANUSCRIPT = <<EOF
<msDesc>
  <additional></additional>
</msDesc>
EOF

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

    class Document

      attr_reader :document, :link_group

      # Legacy attributes
      attr_reader :teiDocument, :headerElement, :textElem, :bookElem, :poemElem, :poemElement

      def initialize()
        @document = Nokogiri::XML(TEI_P5_DOC, &:noblanks)
        # Legacy attribute
        @teiDocument = @document

        # Should resolve issues related to the parsing of certain unicode characters
        @teiDocument.encoding = 'utf-8'

        @textElem = @teiDocument.at_xpath('tei:TEI/tei:text/tei:body', TEI_NS)

        # There are no poems which are isolated from an identified source
        @bookElem = @textElem.at_xpath('tei:div', TEI_NS)

        @workType = POEM

        # To each <div> shall be delegated a transcription file
        # Extract and strip certain metadata values at the document level
        # Extract the document ID
        @poemElem = @bookElem.at_xpath('tei:div', TEI_NS)
        @poemElement = @poemElem

        # Link Group
        @link_group = TeiLinkGroup.new @poemElem

        @headerElement = @teiDocument.at_xpath('tei:TEI/tei:teiHeader', TEI_NS)
      end

      def to_xml
        @teiDocument.to_xml
      end

    end
  end

  

  class TeiHeader
    
  end

  class TeiText

  end

  # <tei:body>
  # This contains the logical headnote sets, headnotes, and footnote set
  class TeiBody
  end

  # Logical, a set of <tei:title> Elements
  class TeiTitleSet
  end

  # <tei:title> Elements
  class TeiTitle
  end

  # Logical set of <tei:note type="head">
  class TeiHeadnoteSet
  end

  # <tei:note type="head"> Elements
  class TeiHeadnote
  end

  # Module for handling SPP-specific formatting
  module SwiftPoemsProjectPoem

    # The Class for the identifier within a given poem/letter
    class ID

      attr_reader :value

      # Create a new poem ID
      def initialize(value)
        raise NotImplementedError.new "Attempted to mint a poem ID using a blank token" if value.empty?
        @value = value
      end
    end

    # Parse the poem ID from a token
    def self.parse_id(token)
      begin

        # Remove the 8 character identifier from the beginning of the line
        # @todo Refactor and remove redundancy here
        poem_id_match = /\s*(\d+)\s+/.match token
        poem_id_match = /([0-9A-Z\!\-]{8})   /.match(token) if not poem_id_match
        poem_id_match = /([0-9A-Z]{8})   /.match(token) if not poem_id_match
        
        if not poem_id_match
          raise NotImplementedError.new "Could not extract the Poem ID from #{token}"
        else
          value = poem_id_match.to_s.strip
          ID.new(value)
        end
        
      rescue Exception => e
        nil
      end
    end

    # Handling SPP-specific formatting at the level of lines
    module Line
      # The Class for a poem line number
      class Number

        attr_reader :value

        # Create a new line number
        def initialize(value)
          raise NotImplementedError.new "Attempted to mint a line number using a blank token" if value.empty?
          @value = value
        end
      end

      # Parse the line number from a token
      def self.parse_number(token)
        
        begin
          line_number_match = /\s*(\d{1,4})\s+/.match token
        
          if not line_number_match
            raise NotImplementedError.new "Could not extract the line number from #{token}"
          else
            value = line_number_match.to_s.strip
            Number.new(value)
          end
        
        rescue Exception => e

          puts "warning: #{e}"
          nil
        end
      end
    end
  end
end
