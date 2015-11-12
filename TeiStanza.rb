# -*- coding: utf-8 -*-

module SwiftPoemsProject


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

      @current_line_number = options.fetch :current_line_number, 1

      # If there is an open tag...
      # if not @opened_tags.empty?
      lineElem = TeiLine.new @workType, self, { :footnote_index => @footnote_index, :number => @current_line_number }

      @lines = [ lineElem ]
    end

    # Push an empty <l> element without an @n attribute value
    # Resolves SPP-213
    def pushEmptyLine

      newLine = TeiLine.new @workType, self
      @lines << newLine
    end

    # Push a new line into the stanza
    #
    def pushLine

      @current_line_number += 1
      @footnote_index = @lines.last.footnote_index
      newLine = TeiLine.new @workType, self, { :footnote_index => @footnote_index, :number => @current_line_number }

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

      previous_lines = @poemElem.xpath("tei:lg[ (@type='#{@elem['type']}' or @type='triplet') and @n='#{previous_stanza_index}']/tei:l[@n]", TEI_NS)
      previous_line = previous_lines.last
    end

    def next_line_index

      return '1' if previous_line.nil? or previous_line['n'].nil?

      next_line_index = (previous_line['n'].to_i) + 1
      return next_line_index.to_s
    end

    # For cases in which a new stanza is created within a single line, the line numbers are duplicated
    # This breaks for the collation, which assumed a one-to-one line mapping
    def align_previous_line

      raise TeiIndexError.new "The previous stanza has no indexed lines: #{@poemElem.to_xml}" if previous_line.nil?

      previous_line['xml:id'] = previous_line['xml:id'] + '-a'
      previous_line.delete('n')
    end

    def push(token)

      # Work-around for completely empty lines
      if @lines.length == 1 and @lines.last.elem.content.empty?

        token = token.sub POEM_ID_PATTERN, ''
        @current_line_number = @lines.last.push token
      else

        # Note: There are not indices larger than 999
        token_is_index = /^\d{1,3}$/.match token.strip

        # Trigger a new line
        # @todo Refactor with a single regular expression
        if POEM_ID_PATTERN.match token

          token = token.sub POEM_ID_PATTERN, ''
          pushLine unless token.strip.empty? or token_is_index
        end
        
        token = token.sub /\r/, ''
        token = token.sub(/^[0-9A-Z\!\-]{8}/, '').strip if token.sub(/^[0-9A-Z\!\-]{8}/, '').strip.empty?

        @current_line_number = @lines.last.push token unless token.strip.empty?
      end

      return @current_line_number
    end

  end
end
