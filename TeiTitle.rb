# -*- coding: utf-8 -*-

module SwiftPoemsProject

  class TeiTitle

    attr_reader :elem, :tokens
    attr_accessor :has_opened_tag, :current_leaf

    def initialize(document, header)

      @document = document
      @header = header
      @headerElement = header.elem

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
    
    def pushToken(token)

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

      # If this is the first line, or, if this tag must be closed...
      elsif NB_MARKUP_TEI_MAP.has_key? @current_leaf.name
        
        # Does this seem to close the current leaf?
        if NB_MARKUP_TEI_MAP[@current_leaf.name].has_key? token
          
          # One cannot resolve the tag name and attributes until both tags have been fully parsed
          # @current_leaf.name = NB_MARKUP_TEI_MAP[@current_leaf.name][token].keys[0]
          # @current_leaf = @current_leaf.parent

          @current_leaf.close(token)
          
          @has_opened_tag = false
          
          # Recurse through previously opened tags
          # raise NotImplementedError, @header.opened_tags if not @header.opened_tags.empty?
          
          opened_tag = @header.opened_tags.first
          # puts opened_tag

          # @todo Resolve
          if NB_MARKUP_TEI_MAP.has_key? opened_tag.name and NB_MARKUP_TEI_MAP[opened_tag.name] != nil

            while opened_tag and NB_MARKUP_TEI_MAP.has_key? opened_tag.name and NB_MARKUP_TEI_MAP[opened_tag.name].has_key? token

              closed_tag = @header.opened_tags.shift
=begin

              closed_tag.name = NB_MARKUP_TEI_MAP[closed_tag.name][token].keys[0]
              
              opened_tag = @header.opened_tags.first
=end

              closed_tag.close(token)
            end
          elsif not @header.opened_tags.empty? and opened_tag.name == 'hi'



            closed_tag = @header.opened_tags.shift
            opened_tag = @header.opened_tags.first

#            raise NotImplementedError

          end
        else
          
          # Add a new child node to the current leaf
          # Temporarily use the token itself as a tagname
          # newLeaf = Nokogiri::XML::Node.new token, @document
          # @current_leaf.add_child newLeaf
          # @current_leaf = newLeaf

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
      if /_\|/.match token
        
        @current_leaf.add_child Nokogiri::XML::Node.new 'lb', @document
      else
        
        @current_leaf.add_child Nokogiri::XML::Text.new token, @document
      end
    end
    
    def push(token)

      puts "Adding the following token to title: " + token

      if NB_SINGLE_TOKEN_TEI_MAP.has_key? token or (NB_TERNARY_TOKEN_TEI_MAP.has_key? @current_leaf.name and NB_TERNARY_TOKEN_TEI_MAP[@current_leaf.name][:secondary].has_key? token) or (NB_MARKUP_TEI_MAP.has_key? @current_leaf.name and NB_MARKUP_TEI_MAP[@current_leaf.name].has_key? token) or NB_MARKUP_TEI_MAP.has_key? token
        
        pushToken token
      else
        
        pushText token
      end
    end
  end
end
