# -*- coding: utf-8 -*-

module SwiftPoemsProject

  class TeiPoemHeads

    attr_reader :elem
    attr_accessor :opened_tags

    def initialize(elem, index, options = {})

      @elem = elem
      @document = elem.document
      @opened_tags = []

      @footnote_index = options[:footnote_index] || 0
      
      @heads = [ TeiHead.new(@document, self, index, { :footnote_index => @footnote_index }) ]
    end
    
    def pushHead

      last_head = @heads.last

      @heads << TeiHead.new(@document, self, @heads.last.elem['n'].to_i + 1, { :footnote_index => @heads.last.footnote_index })
      @heads.last.has_opened_tag = last_head.has_opened_tag

      # @todo Refactor with pushTitle
      if @heads.last.has_opened_tag

        @opened_tags.unshift last_head.current_leaf
        @heads.last.current_leaf = @heads.last.elem.add_child Nokogiri::XML::Node.new last_head.elem.children.last.name, @document
      end
    end

    def push(token)

      # puts "Pushing the token #{token}..."

      if @heads.length == 1 and @heads.last.elem.content.empty?

        #token = token.sub /\s\|\s/, ''
        @heads.last.push token
      else

        # Trigger a new line
        #if /\s\|\s/.match token

        #  pushHead
        #  token = token.sub /\s\|\s/, ''
        #end

        token = token.sub /\r/, ''
        @heads.last.push token
      end
    end

    def close(token)

      token = token.sub /\r/, ''
      @heads.last.push token
      pushHead
      
      @heads.map { |title| title.elem }
    end
  end
end
