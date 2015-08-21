# -*- coding: utf-8 -*-

module SwiftPoemsProject

  POEM = 'poem'
  LETTER = 'letter'

  # 991A002D
# POEM_ID_PATTERN = /[A-Z\d]\d\d\-?[0-9A-Z\!\-]{4,5}\s+/
  POEM_ID_PATTERN = /[0-9A-Z\!\-]{8}\s{3}/
  # ^[0-9a-zA-Z\-]{8}\s{3}

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
    /(?<!«MDNM»|«FN1)·/ => ' ',
    /─ / => '─'    
  }

  # The XML TEI namespace
  TEI_NS = {'tei' => 'http://www.tei-c.org/ns/1.0'}

  class TeiStanza

    attr_reader :poem, :document, :elem, :footnote_index, :lines
    attr_accessor :opened_tags

    def initialize(poem, workType, index, options = {})

      @poem = poem
      @workType = workType
       
      @poemElem = poem.element
      @teiDocument = @poemElem.document
      @document = @teiDocument
       
      @blockElemName = 'lg'

      @elem = Nokogiri::XML::Node.new @blockElemName, @teiDocument
      @elem['n'] = index.to_s
      @elem['type'] = @workType == POEM ? 'stanza' : 'verse-paragraph' # Resolves SPP-245

      @opened_tags = options[:opened_tags] || []
      @line_has_opened_tag = options[:line_has_opened_tag] || !@opened_tags.empty?

      # Extending the Class in order to support footnote indexing
      # SPP-156
      @footnote_index = options[:footnote_index] || 0

      @poemElem.add_child(@elem)

      # If there is an open tag...
      # if not @opened_tags.empty?
      lineElem = TeiLine.new @workType, self, { :footnote_index => @footnote_index }

      @lines = [ lineElem ]
    end

    # Push an empty <l> element without an @n attribute value
    # Resolves SPP-213
    def pushEmptyLine

      newLine = TeiLine.new @workType, self
      @lines << newLine
    end

    def pushLine

      @footnote_index = @lines.last.footnote_index
      newLine = TeiLine.new @workType, self, { :footnote_index => @footnote_index }

      @lines << newLine
    end

    def push_line_break(line_break = '_')

      @lines.last.push_line_break(line_break)
    end

    def push_line_indent(indent = '|')

      @lines.last.push_line_indent(indent)
    end

    # Retrieve the previous line within a stanza
    def previous_line

      if @elem['n'] == '1'

        previous_stanza_index = @elem['n']
      else

        previous_stanza_index = @elem['n'].to_i - 1
      end

      previous_lines = @poemElem.xpath("tei:lg[@type='#{@elem['type']}' and @n='#{previous_stanza_index}']/tei:l[@n]", TEI_NS)
      previous_line = previous_lines.last
    end

    def next_line_index

      return '1' if previous_line.nil? or previous_line['n'].nil?

      next_line_index = (previous_line['n'].to_i) + 1
      return next_line_index.to_s
    end

    def push(token)

      # Work-around for completely empty lines
      if @lines.length == 1 and @lines.last.elem.content.empty?

        if @elem['n'].to_i > 1

          # Update the line number
          raise TeiIndexError.new "The previous stanza has no indexed lines: #{@poemElem.to_xml}" if previous_line.nil?

          line_index = previous_line['n'].to_i + 1
          # @lines.last.elem['n'] = line_index.to_s
          @lines.last.number=line_index.to_s
        end

        token = token.sub POEM_ID_PATTERN, ''
        @lines.last.push token
      else

        # Note: There are not indices larger than 999
        token_is_index = /^\d{1,3}$/.match token.strip

        # Trigger a new line
        # @todo Refactor with a single regular expression
        if POEM_ID_PATTERN.match token

          token = token.sub POEM_ID_PATTERN, ''
          pushLine unless token.strip.empty? or token_is_index

#        elsif /([0-9A-Z\-]{8})\s+/.match token

#          token = token.sub /([0-9A-Z\-]{8})\s+/, ''
#          pushLine unless token.strip.empty? or token_is_index
        end
        
        token = token.sub /\r/, ''

        if token_is_index

          pushEmptyLine
        end

        if token_is_index

          # @lines.last.elem['n'] = /^\d+$/.match token.strip
          @lines.last.number=/^\d+$/.match token.strip
        else

          @lines.last.push token unless token.strip.empty?
        end

#        puts 'trace5'
#        puts @elem.to_xml

#        puts 'trace6'
#        puts @opened_tags

#        puts 'trace7'

        # Insert the line number
        unless @lines.last.elem.has_attribute? 'n'

          # For cases such as isolated tokens
          if token.strip == 'om.'

            # @lines.last.elem['n'] = @lines[-2].elem['n'].to_i + 1
            @lines.last.number=@lines[-2].elem['n'].to_i + 1
          else

            # For cases in which a new stanza was appended
            # @lines.last.elem['n'] = previous_line['n'] if previous_line and not previous_line.content.empty?
            @lines.last.number=previous_line['n'] if previous_line and not previous_line.content.empty?
          end
        end
      end
    end
  end
end
