# -*- coding: utf-8 -*-

module SwiftPoemsProject

  class TeiHead
    
    attr_reader :elem, :footnote_index
    attr_accessor :has_opened_tag, :current_leaf
    
    def initialize(document, poem, index, options = {})
      
      @document = document
      @poem = poem

      @elem = Nokogiri::XML::Node.new('head', @document)
      @elem['type'] = 'note'
      @elem['n'] = index
      
      @poem.elem.add_child @elem

      # Insert handling for paragraphs within headnotes
      @current_leaf = @elem.add_child Nokogiri::XML::Node.new 'lg', @document
      @paragraph_index = 1
      @current_leaf['n'] = @paragraph_index

      # Resolves SPP-244
      # @todo Refactor
      @current_leaf['type'] = 'headnote'

      # Resolves SPP-243
      # @todo Refactor
      @current_leaf = @current_leaf.add_child Nokogiri::XML::Node.new 'l', @document
      @current_leaf['n'] = 1

      @tokens = []

      @footnote_opened = false
      @flush_left_opened = false
      @flush_right_opened = false

      # SPP-156
      @footnote_index = options[:footnote_index] || 0
    end
    
    def pushToken(token)

      # Hard-coding support for footnote parsing
      # @todo Refactor
      if NB_MARKUP_TEI_MAP.has_key? @current_leaf.name and not /«FN./.match(token)

        if NB_TERNARY_TOKEN_TEI_MAP.has_key? @current_leaf.name and NB_TERNARY_TOKEN_TEI_MAP[@current_leaf.name][:secondary].has_key? token

          # puts 'trace6: closing a ternary tag'

          # One cannot resolve the tag name and attributes until both tags have been fully parsed
          
          # Set the name of the current token from the map
          @current_leaf.name = NB_TERNARY_TOKEN_TEI_MAP[@current_leaf.name][:secondary][token].keys[0]
          @current_leaf = @current_leaf.parent

          newLeaf = Nokogiri::XML::Node.new token, @document
          @current_leaf.add_child newLeaf
          @current_leaf = newLeaf
        elsif NB_MARKUP_TEI_MAP[@current_leaf.name].has_key? token # If this token closes the currently opened token

          if /^«FN/.match @current_leaf.name and /»/.match token

            @footnote_index += 1
            @current_leaf['n'] = @footnote_index
          end

          # Iterate through all of the markup and set the appropriate TEI attributes
          attribMap = NB_MARKUP_TEI_MAP[@current_leaf.name][token].values[0]
          @current_leaf[attribMap.keys[0]] = attribMap[attribMap.keys[0]]

          # One cannot resolve the tag name and attributes until both tags have been fully parsed
          @current_leaf.name = NB_MARKUP_TEI_MAP[@current_leaf.name][token].keys[0]
          @current_leaf = @current_leaf.parent
         
          @has_opened_tag = false
          
          opened_tag = @poem.opened_tags.first

          while not opened_tag.nil? and NB_MARKUP_TEI_MAP.has_key? opened_tag.name and NB_MARKUP_TEI_MAP[opened_tag.name].has_key? token

            closed_tag = @poem.opened_tags.shift

            closed_tag_name = NB_MARKUP_TEI_MAP[closed_tag.name][token].keys[0]

            # @todo Integrate Nota Bene Delta Objects
            NB_MARKUP_TEI_MAP[closed_tag.name][token][closed_tag_name].each_pair do |attrib_name, attrib_value|

              closed_tag[attrib_name] = attrib_value
            end
            closed_tag.name = closed_tag_name

            opened_tag = @poem.opened_tags.first
          end

          # Work-around for "overridden" Nota Bene Deltas
          if not( /^«FN/.match @current_leaf.name and /»/.match token) and token != '«MDNM»'
            
            # Add the cloned token
            
            newLeaf = Nokogiri::XML::Node.new token, @document
            @current_leaf.add_child newLeaf
            @current_leaf = newLeaf
            @has_opened_tag = true

            @poem.opened_tags.unshift @current_leaf
          end

        elsif NB_MARKUP_TEI_MAP.has_key? token

          # Add a new child node to the current leaf
          # Temporarily use the token itself as a tagname
          newLeaf = Nokogiri::XML::Node.new token, @document
          @current_leaf.add_child newLeaf
          @current_leaf = newLeaf
          @has_opened_tag = true

          @poem.opened_tags.unshift @current_leaf
        elsif NB_SINGLE_TOKEN_TEI_MAP.has_key? token

          newLeaf = Nokogiri::XML::Node.new token, @document

          newLeaf.name = NB_SINGLE_TOKEN_TEI_MAP[token].keys[0]

          NB_SINGLE_TOKEN_TEI_MAP[token][newLeaf.name].each do |name, value|

            newLeaf[name] = value
          end

          @current_leaf.add_child newLeaf

          # @flush_left_opened = /«FC»/.match(token)
          # @flush_right_opened = /«LD ?»/.match(token)
          @flush_left_opened = false
          @flush_right_opened = false

        else
          
          raise NotImplementedError.new "Unhandled token: #{token}"
        end

      elsif @flush_right_opened or @flush_left_opened or @footnote_opened # @todo Refactor

        # Add a new child node to the current leaf
        # Temporarily use the token itself as a tagname
        newLeaf = Nokogiri::XML::Node.new token, @document

        # newLeaf.name = NB_SINGLE_TOKEN_TEI_MAP[token].keys[0]
        @current_leaf.name = NB_SINGLE_TOKEN_TEI_MAP[token].keys[0]

        @current_leaf.add_child newLeaf
        @current_leaf = newLeaf
        # @has_opened_tag = true

      elsif NB_SINGLE_TOKEN_TEI_MAP.has_key? token

        newLeaf = Nokogiri::XML::Node.new token, @document

        newLeaf.name = NB_SINGLE_TOKEN_TEI_MAP[token].keys[0]

        NB_SINGLE_TOKEN_TEI_MAP[token][newLeaf.name].each do |name, value|

          newLeaf[name] = value
        end

        @current_leaf.add_child newLeaf
        @current_leaf = newLeaf

        # @flush_left_opened = /«FC»/.match(token)
        # @flush_right_opened = /«LD ?»/.match(token)
        @flush_left_opened = false
        @flush_right_opened = false

      else

        # Add a new child node to the current leaf
        # Temporarily use the token itself as a tagname
        newLeaf = Nokogiri::XML::Node.new token, @document
        @current_leaf.add_child newLeaf
        @current_leaf = newLeaf
        @has_opened_tag = true


        @poem.opened_tags.unshift @current_leaf
        # @footnote_opened = /«FN?/.match(token)

=begin
      else
        
        # Add a new child node to the current leaf
        # Temporarily use the token itself as a tagname
        # @todo Refactor
        newLeaf = Nokogiri::XML::Node.new token, @document
        @current_leaf.add_child newLeaf
        @current_leaf = newLeaf
        @has_opened_tag = true
      end
=end
      end
      
      @tokens << token
    end
    
    # Add this as a text node for the current line element
    def pushText(token)

      # puts 'appending the following text token: ' + token

      raise NotImplementedError.new "Failure to parse the following token within a headnote: #{token}" if /«.{2}/.match token

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
      
      if token == '|'
        
        @current_leaf.add_child Nokogiri::XML::Node.new 'lb', @document
      else
        
        @current_leaf.add_child Nokogiri::XML::Text.new token, @document
      end
    end

    def pushParagraph

      @current_leaf = @current_leaf.parent.parent
      new_paragraph = Nokogiri::XML::Node.new 'lg', @document
      @paragraph_index += 1
      new_paragraph['n'] = @paragraph_index

      @current_leaf.add_child new_paragraph

      @current_leaf = new_paragraph

      # Resolves SPP-244
      # @todo Refactor
      @current_leaf['type'] = 'headnote'

      # Resolves SPP-243
      # @todo Refactor
      @current_leaf = @current_leaf.add_child Nokogiri::XML::Node.new 'l', @document
      @current_leaf['n'] = 1

      if not @poem.opened_tags.empty?

        prev_opened_tag = @poem.opened_tags.first
        current_opened_tag = Nokogiri::XML::Node.new prev_opened_tag.name, @document

        @current_leaf.add_child current_opened_tag
        @current_leaf = current_opened_tag
      end

      # Implement handling for opened tags
      # puts 'trace3: ' + @poem.opened_tags.to_s
      # puts 'currently opened tag: ' + @current_leaf.parent.to_xml
    end
    
    def push(token)

      if token == '_'

        # 
        pushParagraph

        # puts 'trace2: ' + @poem.opened_tags.to_s

      elsif NB_SINGLE_TOKEN_TEI_MAP.has_key? token or
          (NB_TERNARY_TOKEN_TEI_MAP.has_key? @current_leaf.name and NB_TERNARY_TOKEN_TEI_MAP[@current_leaf.name][:secondary].has_key? token) or
          (NB_MARKUP_TEI_MAP.has_key? @current_leaf.name and NB_MARKUP_TEI_MAP[@current_leaf.name].has_key? token) or
          NB_MARKUP_TEI_MAP.has_key? token
        
        pushToken token
      else
        
        pushText token
      end
    end
  end
end
