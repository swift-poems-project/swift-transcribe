# -*- coding: utf-8 -*-

module SwiftPoemsProject

  class Title

    attr_reader :elem, :tokens, :footnote_index
    attr_accessor :has_opened_tag, :current_leaf

    def initialize(header, poem_id, options = {})

      @header = header
      @document = @header.document

      @id = poem_id

      @headerElement = header.elem

      @footnote_index = options[:footnote_index] || 0
      @mode = options.fetch(:mode, READING)

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

      @xml_id = "spp-#{@id}-title-#{line_number}"
      @elem['xml:id'] = @xml_id
    end

    def number(value, element)

      element['n'] = value

      # Update the xml:id value
      mint_xml_id value
    end

    def number=(value)

      number value
    end
    
    def pushToken(token)

      # If this is the first line, or, if this tag must be closed...
      if NB_MARKUP_TEI_MAP.has_key? @current_leaf.name

        # Does this seem to close the current leaf?
        if NB_MARKUP_TEI_MAP[@current_leaf.name].has_key? token

          # Implementing handling for footnote index generation
          # SPP-156
          if /^«FN1/.match @current_leaf.name and /\.?»$/.match token

            @footnote_index += 1
            # @current_leaf['n'] = @footnote_index
            number @footnote_index, @current_leaf.element

            # Link the footnotes to the lineGroup for the poem
            # Add more complexity for the footnotes
            # SPP-253
            # @todo Refactor
            footnote_xml_id = "spp-#{@id}-footnote-title-#{@footnote_index}"
            @current_leaf.element['xml:id'] = footnote_xml_id

            target = "##{footnote_xml_id}"
            source = "##{@xml_id}"

            # Add an inline <ref> element
            ref = Nokogiri::XML::Node.new 'ref', @document
            ref.content = @footnote_index
            ref['target'] = target
            @current_leaf.element.add_previous_sibling ref
         
            # Add an element to <linkGrp>
#            @header.poem.link_group.add_link target, source
            @header.transcript.tei.link_group.add_link target, source
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
        elsif NB_SINGLE_TOKEN_TEI_MAP.has_key? token

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
        @current_leaf = BinaryNotaBeneDelta.new(token, @document, @current_leaf)

        @has_opened_tag = true
        @header.opened_tags << @current_leaf

        
      end

      @tokens << token
    end

    # Add this as a text node for the current line element
    def pushText(token)

      # Remove the 8 character identifier from the beginning of the line
      indexMatch = /\s{3}(\d+)\s{2}/.match token
      if indexMatch
        
        # @elem['n'] = indexMatch.to_s.strip
        number indexMatch.to_s.strip
        token = token.sub /\s{3}(\d+)\s{2}/, ''
      end

      # Replace all Nota Bene deltas with UTF-8 compliant Nota Bene deltas
      NB_ASCII_SEQS.each_pair do |ascii_seq, utf8_seq|
        token = token.gsub(ascii_seq, utf8_seq)
      end

      # Obviously this cannot handle multiple line breaks (!)
      if /_/.match token and @mode == READING
        @current_leaf.add_child Nokogiri::XML::Node.new 'lb', @document
        token = token.sub(/_/, '')
        # token = token.lstrip
      end

      if /\|/.match token and @mode == READING
        # Disable this in order to ensure that pipes do not encode line breaks (as requested by the PI)
        @current_leaf.add_child Nokogiri::XML::Node.new 'lb', @document
        token = token.sub(/\|/, '')
      end

      @current_leaf.add_child Nokogiri::XML::Text.new token, @document
    end
    
    def push(token)

      # For the purposes of legibility
      is_a_closing_ternary_token = NB_TERNARY_TOKEN_TEI_MAP.has_key?(@current_leaf.name) && NB_TERNARY_TOKEN_TEI_MAP[@current_leaf.name][:secondary].has_key?(token)
      is_a_closing_token = NB_MARKUP_TEI_MAP.has_key?(@current_leaf.name) && NB_MARKUP_TEI_MAP[@current_leaf.name].has_key?(token)
      
      if NB_SINGLE_TOKEN_TEI_MAP.has_key? token or is_a_closing_ternary_token or is_a_closing_token or NB_MARKUP_TEI_MAP.has_key? token
        pushToken token
      else
        pushText token
      end
    end
  end
end
