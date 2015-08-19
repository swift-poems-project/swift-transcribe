# -*- coding: utf-8 -*-

module SwiftPoemsProject

  class TeiTitle

    attr_reader :elem, :tokens, :footnote_index
    attr_accessor :has_opened_tag, :current_leaf

    def initialize(header, id, options = {})

      @header = header.document
      @document = @header.document

      @id = id

      @headerElement = header.elem

      @footnote_index = options[:footnote_index] || 0

      @elem = Nokogiri::XML::Node.new('title', @document)
      
      @current_leaf = @elem
      @tokens = []
      
      # Add <title> elements directly underneath the <sponsor> element
      # @headerElement.at_xpath('tei:fileDesc/tei:titleStmt/tei:sponsor', TEI_NS).add_previous_sibling(@elem)

      # The opened tags from the previous title need to be modified
=begin
      if last_title.has_opened_tag

        @opened_tags.last.name = last_title.tokens.last
      end
=end
    end

    # Mint the unique line identifier
    #
    def mint_xml_id(line_number)

      @xml_id = "#{@id}-title-#{line_number}"
      @elem['xml:id'] = @xml_id
    end

    def number=(number)

      @elem['n'] = number

      # Update the xml:id value
      mint_xml_id @elem['n']
    end
    
    def pushToken(token)

=begin
      if NB_TERNARY_TOKEN_TEI_MAP.has_key? @current_leaf.name and NB_TERNARY_TOKEN_TEI_MAP[@current_leaf.name][:secondary].has_key? token

        # One cannot resolve the tag name and attributes until both tags have been fully parsed
        @current_leaf.name = NB_TERNARY_TOKEN_TEI_MAP[@current_leaf.name][:secondary][token].keys[0]
        @current_leaf = @current_leaf.parent

        # Add a new child node to the current leaf
        # Temporarily use the token itself as a tagname
        newLeaf = Nokogiri::XML::Node.new token, @document
        @current_leaf.add_child newLeaf
        @current_leaf = newLeaf
        @has_opened_tag = true
        @header.opened_tags << @current_leaf
=end

      # If this is the first line, or, if this tag must be closed...
#      elsif NB_MARKUP_TEI_MAP.has_key? @current_leaf.name
      if NB_MARKUP_TEI_MAP.has_key? @current_leaf.name

        # Does this seem to close the current leaf?
        if NB_MARKUP_TEI_MAP[@current_leaf.name].has_key? token

          # puts 'trace36: ' + token

          # Implementing handling for footnote index generation
          # SPP-156
          if /^«FN1/.match @current_leaf.name and /»$/.match token

            @footnote_index += 1
            @current_leaf['n'] = @footnote_index
          end

          # @todo Resolve
          if @current_leaf.class.to_s == 'Nokogiri::XML::Element'

            closed_tag_name = NB_MARKUP_TEI_MAP[@current_leaf.name][token].keys[0]

            NB_MARKUP_TEI_MAP[@current_leaf.name][token][closed_tag_name].each_pair do |attrib_name, attrib_value|

              @current_leaf[attrib_name] = attrib_value
            end
            @current_leaf.name = closed_tag_name
          else
          
            @current_leaf.close(token)
          end

          @current_leaf = @current_leaf.parent
          @has_opened_tag = false
          
          # Recurse through previously opened tags
          # raise NotImplementedError, @header.opened_tags if not @header.opened_tags.empty?

          debug_opened_tags = @header.opened_tags.map { |tag| tag.to_xml }
          # puts 'trace 23: ' + debug_opened_tags.to_s
          
          opened_tag = @header.opened_tags.first

          # @todo Resolve
          if NB_MARKUP_TEI_MAP.has_key? opened_tag.name and NB_MARKUP_TEI_MAP[opened_tag.name] != nil

            while opened_tag and NB_MARKUP_TEI_MAP.has_key? opened_tag.name and NB_MARKUP_TEI_MAP[opened_tag.name].has_key? token

              closed_tag = @header.opened_tags.shift

              if closed_tag.class.to_s == 'Nokogiri::XML::Element'

                closed_tag_name = NB_MARKUP_TEI_MAP[closed_tag.name][token].keys[0]

                NB_MARKUP_TEI_MAP[closed_tag.name][token][closed_tag_name].each_pair do |attrib_name, attrib_value|

                  closed_tag[attrib_name] = attrib_value
                end
                closed_tag.name = closed_tag_name
              else

                closed_tag.close(token)
              end
            end
          elsif not @header.opened_tags.empty? and opened_tag.name == 'hi'

            # @todo Refactor
            closed_tag = @header.opened_tags.shift
            opened_tag = @header.opened_tags.first
          end
        else

          # Add a new child node to the current leaf
          # Temporarily use the token itself as a tagname
          # @todo Refactor
          @current_leaf = BinaryNotaBeneDelta.new(token, @document, @current_leaf)

          @has_opened_tag = true
          @header.opened_tags << @current_leaf
        end

      elsif NB_SINGLE_TOKEN_TEI_MAP.has_key? token

        # newLeaf = Nokogiri::XML::Node.new NB_SINGLE_TOKEN_TEI_MAP[token].keys[0], @document
        # @current_leaf.add_child newLeaf

        if NB_DELTA_FLUSH_TEI_MAP.has_key? token

          current_leaf = FlushDelta.new(token, @document, @current_leaf)
        elsif NB_DELTA_ATTRIB_TEI_MAP.has_key? token

          current_leaf = AttributeNotaBeneDelta.new(token, @document, @current_leaf)
        else

          current_leaf = UnaryNotaBeneDelta.new(token, @document, @current_leaf)
        end
      else

        # Add a new child node to the current leaf
        # Temporarily use the token itself as a tagname
        # @todo Refactor
#        newLeaf = Nokogiri::XML::Node.new token, @document
#        @current_leaf.add_child newLeaf
#        @current_leaf = newLeaf

        @current_leaf = BinaryNotaBeneDelta.new(token, @document, @current_leaf)

        @has_opened_tag = true
        @header.opened_tags << @current_leaf

        
      end

      # puts "\n" + @header.opened_tags.to_s + "\n"

      @tokens << token
    end

    # Add this as a text node for the current line element
    def pushText(token)

      # Remove the 8 character identifier from the beginning of the line
      indexMatch = /\s{3}(\d+)\s{2}/.match token
      if indexMatch
        
        @elem['n'] = indexMatch.to_s.strip
        token = token.sub /\s{3}(\d+)\s{2}/, ''
      end

      # Replace all Nota Bene deltas with UTF-8 compliant Nota Bene deltas
      NB_CHAR_TOKEN_MAP.each do |nbCharTokenPattern, utf8Char|
        
        token = token.gsub(nbCharTokenPattern, utf8Char)
      end

      # if token == '_|'
      if /_?\|/.match token

        @current_leaf.add_child Nokogiri::XML::Node.new 'lb', @document
      else
        
        @current_leaf.add_child Nokogiri::XML::Text.new token, @document
      end
    end
    
    def push(token)

      # puts "Adding the following token to title: " + token
      # puts 'trace 38: ' + NB_MARKUP_TEI_MAP[@current_leaf.name].has_key?('«MDNM»').to_s if NB_MARKUP_TEI_MAP.has_key? @current_leaf.name

      if NB_SINGLE_TOKEN_TEI_MAP.has_key? token or (NB_TERNARY_TOKEN_TEI_MAP.has_key? @current_leaf.name and NB_TERNARY_TOKEN_TEI_MAP[@current_leaf.name][:secondary].has_key? token) or (NB_MARKUP_TEI_MAP.has_key? @current_leaf.name and NB_MARKUP_TEI_MAP[@current_leaf.name].has_key? token) or NB_MARKUP_TEI_MAP.has_key? token
        
        pushToken token

      else
        
        pushText token
      end
    end
  end
end
