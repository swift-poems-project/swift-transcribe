# -*- coding: utf-8 -*-
module SwiftPoemsProject

  # Constants

  # Types of documents
  POEM = 'poem'
  LETTER = 'letter'

  # Regular expression for extracting poem ID's
  POEM_ID_PATTERN = /[0-9A-Z\!\-]{8}\s{3}\d+\s/

  DECORATOR_PATTERN = /«MD[SUNMD]{2}»\*(«MDNM»$)?/

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
  

  # Module for handling SPP-specific formatting
  module Poem

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
