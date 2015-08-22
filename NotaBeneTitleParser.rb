# -*- coding: utf-8 -*-

require_relative 'NotaBeneHeadFieldParser'

module SwiftPoemsProject

  # One Nota Bene title field value for one TEI <title/> element
  class NotaBeneTitleParser < NotaBeneHeadFieldParser

    class TeiHeader

      attr_reader :sponsor, :elem, :opened_tags, :footnote_index, :document, :poem
      # attr_accessor :opened_tags

      def initialize(parser, id, options = {})

        @elem = parser.element

        # @todo Refactor
        @poem = parser.poem

        @id = id
        @document = elem.document
        @sponsor = @elem.at_xpath('tei:fileDesc/tei:titleStmt/tei:sponsor', TEI_NS)
        @opened_tags = []

        @footnote_index = options[:footnote_index] || 0
        
        @titles = [ SwiftPoemsProject::TeiTitle.new(self, @id, { :footnote_index => @footnote_index }) ]
      end

      def pushTitle
        
        last_title = @titles.last

        # Add additional tokens
        @sponsor.add_previous_sibling @titles.last.elem

        @footnote_index = @titles.last.footnote_index

        @titles << SwiftPoemsProject::TeiTitle.new(self, @id, { :footnote_index => @titles.last.footnote_index })
        @titles.last.has_opened_tag = last_title.has_opened_tag

        if @titles.last.has_opened_tag

          @opened_tags.unshift last_title.current_leaf

          # Work-around
          if /^«/.match last_title.current_leaf.name

            # last_title.current_leaf.name = 'hi'
          end

          if not last_title.tokens.empty?

            @titles.last.current_leaf = @titles.last.elem.add_child Nokogiri::XML::Node.new last_title.tokens.last, @document
          else

            @titles.last.current_leaf = @titles.last.elem.add_child Nokogiri::XML::Node.new last_title.elem.children.last.name, @document
          end
        end

#
        # Close the opened tags
        # Does this seem to close the current leaf?
        # if TeiParser::NB_MARKUP_TEI_MAP[@current_leaf.name].has_key? token
#        if @titles.last.elem.has_opened_tag

          # One cannot resolve the tag name and attributes until both tags have been fully parsed
#          @current_leaf.name = TeiParser::NB_MARKUP_TEI_MAP[@current_leaf.name][token].keys[0]
#          @current_leaf = @current_leaf.parent

#          @has_opened_tag = false
#        end

      end

      def push(token)

        if @titles.length == 1 and @titles.last.elem.content.empty?

          if /\|/.match token

            token = token.sub /\s\|\s/, ''
          end

          @titles.last.push token
        else

          # Trigger a new line
          if /\s\|\s/.match token

            pushTitle
            token = token.sub /\s\|\s/, ''
          end

          token = token.sub /\r/, ''
          @titles.last.push token
        end
      end

      def close(token)
        
        token = token.sub /\r/, ''
        @titles.last.push token
        pushTitle

        # @titles.map { |title| title.elem }
      end
    end

    def clean

      @text = @text.gsub(/«FN1(?!·)/, '«FN1·')
      @text = @text.gsub(/([a-z\.][\d\s]*)»/, '\\1.»')
      @text = @text.gsub(/(['\\,])»/, '\\1.»')

      @text = @text.gsub("«LD »T«MDSD»HOMAS«MDNM» S«MDSD»HERIDAN«MDNM»", ".»T«MDSD»HOMAS«MDNM» S«MDSD»HERIDAN«MDNM»")
      @text = @text.gsub('X13-0802   X13-0802   » S«MDSD»HERIDAN«MDNM».', '')
      @text = @text.gsub('«MDUL» | on his being Steward to the | Duke of«MDNM»', ' | «MDUL» on his being Steward to the «MDNM» | «MDUL» Duke of«MDNM»')

      @text = @text.gsub('P«MDSD»ULTENEY«MDUL»', 'P«MDSD»ULTENEY«MDNM»«MDUL»')
      @text = @text.gsub('The «MDBO»Tale«MDNM» of «MDBO»Ay«MDNM» and «MDBO»No«MDNM».«MDNM»', 'The «MDBO»Tale«MDNM» of «MDBO»Ay«MDNM» and «MDBO»No«MDNM».')
    end

    # Parse the text and append the TEI element to the document
    def parse

      clean

      header = TeiHeader.new(self, @id, { :footnote_index => @footnote_index })

      initialTokens = @text.split /(?=«)|(?=\.»)|(?<=«FN1·)|(?<=»)|(?=\s\|)|(?=_\|)|(?<=_\|)/

      # As there exists no actual terminating character for titles, the index within the array must be used in order to generate the note
      initialTokens[0..-2].each do |initialToken|

        header.push initialToken
      end

      header.close initialTokens.last

      @footnote_index = header.footnote_index
    end
  end
end
