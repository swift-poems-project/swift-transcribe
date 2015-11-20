# -*- coding: utf-8 -*-

require_relative 'NotaBeneHeadFieldParser'

module SwiftPoemsProject

  # One Nota Bene title field value for one TEI <title/> element
  class NotaBeneTitleParser < NotaBeneHeadFieldParser

    class TeiHeader

      attr_reader :sponsor, :elem, :opened_tags, :footnote_index, :document, :poem
      # attr_accessor :opened_tags

      def initialize(parser, id, options = {})

        @element = parser.element

        # @todo Refactor
        @poem = parser.poem

        @id = id
        @document = @element.document
        @sponsor = @element.at_xpath('tei:fileDesc/tei:titleStmt/tei:sponsor', TEI_NS)
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

      @text = @text.gsub(DECORATOR_PATTERN, '')
      @text = @text.gsub(/«MDNM».«MDNM»/, '«MDNM»')
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

    #
    #
    #
    def correct_element(e)

      nota_bene_delta_map = {
        '«MDUL»' => { 'hi' => { 'rend' => 'underline' } },
        '«MDBO»' => { 'hi' => { 'rend' => 'black-letter' } },
        '«MDBR»' => { 'hi' => { 'rend' => 'SMALL-CAPS-ITALICS' } },
        '«MDBU»' => { 'hi' => { 'rend' => 'black-letter' } },
        '«MDDN»' => { 'hi' => { 'rend' => 'strikethrough' } },
        '«MDRV»' => { 'hi' => { 'rend' => 'display-initial' } },
        '«MDSD»' => { 'hi' => { 'rend' => 'SMALL-CAPS' } },
        '«MDSU»' => { 'hi' => { 'rend' => 'sup' } },
        '«FN1·' => { 'note' => { 'place' => 'foot' } },
      }

      e.children.select {|c| c.is_a? Nokogiri::XML::Element }.each do |nota_bene_element|


        if /«.+»/.match nota_bene_element.name
          nota_bene_delta = nota_bene_element.name
          
          raise NotImplementedError.new("Failed to parse the following unencoded token: #{nota_bene_delta}\n#{@element.document}") unless nota_bene_delta_map.has_key? nota_bene_delta
              
          corrected_name = nota_bene_delta_map[nota_bene_delta].keys.first
          corrected_element = Nokogiri::XML::Node.new corrected_name, @element.document
              
          corrected_attribs = nota_bene_delta_map[nota_bene_delta][corrected_name]
          corrected_attribs.each_pair do |attrib_name, attrib_value|
                
            corrected_element[attrib_name] = attrib_value
          end
              
          if nota_bene_element.children.empty?
                
            corrected_element.remove
            nota_bene_element.remove
          else
              
            corrected_element.add_child nota_bene_element.children
            nota_bene_element.swap corrected_element
            nota_bene_element.remove
          end

          nota_bene_element = corrected_element
        end
        
        if /\|/.match nota_bene_element.content
              
          indent_count = nota_bene_element.content.count('|')
              
          if nota_bene_element.parent.key? 'rend'
                
            nota_bene_element.parent['rend'] = nota_bene_element.parent['rend'] + " indent(#{indent_count})"
          else
                
            nota_bene_element.parent['rend'] = "indent(#{indent_count})"
          end
              
          nota_bene_element.children.select { |element| element.text? }.map { |element| element.content = element.content.gsub(/\|/, '') }
        end

        # Remove the trailing footnote operators
        if /\.»/.match nota_bene_element.content
          nota_bene_element.children.select { |element| element.text? }.map { |element| element.content = element.content.gsub(/\.»/, '') }
        end
            
        if /«.{4}?»/.match nota_bene_element.content
          
          nota_bene_element.children.select { |element| element.text? }.map { |element| element.content = element.content.gsub(/«.{4}?»/, '') }
        end

        correct_element(nota_bene_element)
      end
    end

    # @todo Refactor
    def correct

#      current_element = @element
#      current_element.children.each do |child_element|
      @element.children.each do |child_element|
        correct_element child_element
      end
    end
  end
end
