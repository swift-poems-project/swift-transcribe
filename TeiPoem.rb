# -*- coding: utf-8 -*-

require_relative 'NotaBeneNormalizer'

module SwiftPoemsProject

  NB_BLOCK_LITERAL_PATTERNS = [
                               /(«MDSU»\*\*?«MDSD»\*)+«MDSU»\*«MDNM»\*?/,
                               /#{Regexp.escape("«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»**«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*")}/,
                              ]

#  class TeiIndexError < SwiftPoemsProjectError; end
#  class TeiPoemIdError < SwiftPoemsProjectError; end
  class TeiIndexError < StandardError; end
  class TeiPoemIdError < StandardError; end

  class Poem

    attr_reader :id, :element, :link_group, :stanzas

    def self.normalize(poem)

      poem = NotaBeneNormalizer::normalize poem
      
      NB_BLOCK_LITERAL_PATTERNS.each do |pattern|

        poem = poem.sub pattern, '«UNCLEAR»'
      end

      return poem
    end

    def initialize(transcript, content, id, work_type, element, footnote_index = 0)
      
      @transcript = transcript
      @content = content
      # Legacy attribute
      @poem = @content

      # @id = normalize_id(id)
      @id = id
      @work_type = work_type
      @lg_type = @work_type == POEM ? 'stanza' : 'verse-paragraph'
      @element = element
      
      # Extending for supporting footnote indexing
      # SPP-156
      @footnote_index = footnote_index

      # Normalize sequences of "__" or greater
      # Resolves SPP-230
      @poem = @poem.gsub(/_{2,10}/, '_')

      @tokens = tokenize(@content)
#      @link_group = TeiLinkGroup.new @element
      @link_group = transcript.tei.link_group

      @current_line_number = 0

#      @stanzas = [ TeiStanza.new(self, @work_type, 1, {
#                                   :footnote_index => @footnote_index,
#                                   :current_line_number => @current_line_number
#                                 }) ]

      @stanzas = []
      @opened_tags = []
      
    end

    def tokenize(poem)

      # Handling for the decorator literals
      poem = poem.gsub /«MD[SUNMD]{2}»\*(«MDNM»)?/, ''

      # This splits for each Nota Bene mode code
#      tokens = poem.split /(?=«)|(?=[\.─\\a-z]»)|(?<=«FN1·)|(?<=»)|(?=om\.)|(?<=om\.)|(?=\\)|(?<=\\)|(?=_)|(?<=_)|(?=\|)|(?<=\|)|\n/

      normal_content = []

      # Need to clean on a line by line basis
      # This replaces the (rare) cases where line breaks within footnotes are found and encoded using the "_" character
      # These must be replaced with the "^" character (in order to distinguish these from line breaks within the text, which are encoded differently in TEI)
      poem.each_line do |line|


        # In order to improve legibility
        line_has_footnote_lb = line.index('«FN') && line.index('_') && line.index('.»')

        if line_has_footnote_lb
          while line_has_footnote_lb and line.index('«FN') < line.index('_') and line.index('_') < line.index('.»')
            line = line.sub('_', '^')
            line_has_footnote_lb = line.index('«FN') && line.index('_') && line.index('.»')
          end
        end

        line_has_footnote_indent = line.index('«FN') && line.index('|') && line.index('.»')

        if line_has_footnote_indent
          while line_has_footnote_indent and line.index('«FN') < line.index('|') and line.index('|') < line.index('.»')
            
            # This is anomalous, and is actually cleaning data
            line = line.sub('|', '^')
            line_has_footnote_indent = line.index('«FN') && line.index('|') && line.index('.»')
          end
        end

        normal_content << line
      end

      normal_content = normal_content.join("\n")

      # This splits for each new stanza
      tokens = normal_content.split /_/
#      tokens = poem.split /(?<=_)/
    end
    
    def parse
      @tokens.each do |stanza_content|

        stanza_options = {
          :opened_tags => @opened_tags,
          :footnote_index => @footnote_index,
          :current_line_number => @current_line_number
        }

        # puts "content:"
        # puts stanza_content

        # puts "the following tags are opened from the previous stanza:"
        # puts @opened_tags

        @stanzas << TeiStanza.new(self, stanza_content, @work_type, @stanzas.size + 1, stanza_options)
        @stanzas.last.parse

        @opened_tags = @stanzas.last.opened_tags
        @footnote_index = @stanzas.last.footnote_index
      end
    end

    # Retrieves the last <head> element within the <body> element
    def last_head

      xpath = '//TEI:head'
      elements = @element.xpath(xpath, 'TEI' => 'http://www.tei-c.org/ns/1.0')
      elements.last
    end

    # Retrieve unnumbered lines within all stanzas
    def unnumbered_stanza_lines

      xpath = "//TEI:lg[@type='#{@lg_type}' or @type='triplet']/TEI:l"
      l_elements = @element.xpath(xpath, 'TEI' => 'http://www.tei-c.org/ns/1.0')
    end

    # Retrieve numbered lines within all stanzas
    def stanza_lines(line_number = nil)

      if line_number.nil?

        xpath = "//TEI:lg[@type='#{@lg_type}' or @type='triplet']/TEI:l[@n]"
      else

        xpath = "//TEI:lg[@type='#{@lg_type}' or @type='triplet']/TEI:l[@n='#{line_number}']"
      end

      l_elements = @element.xpath(xpath, 'TEI' => 'http://www.tei-c.org/ns/1.0')
    end

    # Retrieve a line using a line number
    def stanza_line(line_number)

      l_elements = stanza_lines(line_number)
      l_element = l_elements.first
    end

    # Due to the quantity and complexity of certain editorial markup issues, this has been implemented as a post-parsing solution
    # Resolves SPP-239
    def correct
      
      # Find all <l> or <p> elements missing @n attributes, and provide the index
      l_elements = stanza_lines
      
      indices = l_elements.select { |element| not element.has_attribute? 'n' and not element.next_element.nil? }
      indices.each do |element|

        element['n'] = element.previous_element['n'].to_i + 1
      end

      # Reorder elements
      indices = l_elements.select { |element| element.has_attribute?('n') && !element['n'].empty? }.map { |element| element['n'].to_i }

      raise NotImplementedError.new "No ordered elements found!\n\n#{@lg_type}\n\n#{@element.to_xml}" if indices.empty?

      sorted_indices = indices.sort
      valid_range = (sorted_indices.first..sorted_indices.last).to_a

      if sorted_indices.length > valid_range.length

        raise NotImplementedError.new "Duplicate lines found"

        # Handling for duplicated line numbers
        # Using the following example...
        # 207-06G1   43  _«FC»T«MDSD»HE«MDNM» MORAL.«FL»__|Thus did the Trojan wooden horse,
        # ... the token "__" creates a new stanza/line grouping, and hence, a new line
        # However, the following line is explicitly numbered as 44:
        # 207-06G1   44  Conceal a fatal armed force;
        # Hence, the second segment of the broken line, must then, have its index removed
        duplicated_indices = sorted_indices.select{ |index| sorted_indices.count(index) > 1 }.uniq

        duplicated_indices.each do |index|

          prev_l_element = stanza_line(index - 1)

          new_header_element = Nokogiri::XML::Node.new 'head', @element.document
          new_header_element['type'] = @lg_type
          new_header_element['n'] = last_head['n'].to_i + 1

          new_lg_element = new_header_element.add_child Nokogiri::XML::Node.new 'lg', @element.document
          new_l_element = new_lg_element.add_child Nokogiri::XML::Node.new 'l', @element.document
          new_l_element.add_child prev_l_element.children

          prev_l_element.attributes.each_pair do |key, value|

            new_l_element[key] = value
          end
          new_l_element['n'] = '1'

          prev_l_element.remove # Remove the previous node

          # Treat the previous element as a header
          l_element = stanza_line(index)

          # If the index already exists, raise an error
          raise NotImplementedError.new "Duplicate lines found for #{index - 1}\n#{@element.document}" unless stanza_line(index - 1).nil?

          l_element['n'] = "#{index - 1}"
          xml_id = "spp-#{@id}-line-#{index - 1}"
          l_element['xml:id'] = xml_id

          l_element.add_previous_sibling new_header_element
        end
      else

        valid_range.each_index do |i|

          # Work-around
          # @todo Refactor
          next if sorted_indices[i].to_s.empty?

          if sorted_indices[i] != valid_range[i]

            elements = stanza_lines(sorted_indices[i])

            if elements.empty?

              xpath = "//TEI:lg[@type='#{@lg_type}']/TEI:l[@n='#{sorted_indices[i]}']"
              # raise NotImplementedError.new "No Elements found using #{xpath}\n#{@element.to_xml}"
              raise NotImplementedError.new "No Elements found using #{xpath}"
            elsif elements.length > 1

              xpath = "//TEI:lg[@type='#{@lg_type}']/TEI:l[@n='#{sorted_indices[i]}']"
              raise NotImplementedError.new "Multiple Elements found using #{xpath}\n#{@element.to_xml}"
              # raise NotImplementedError.new "Multiple Elements found using #{xpath}"
            else
              
              element = elements.shift

              previous_element = element.previous_element

              if previous_element.nil?

                # Retrieve the previous stanza
                # previous_stanza = element.parent.previous_element
                previous_stanza_index = element.parent['n'].to_i - 1
                previous_stanza = element.parent.parent.xpath("TEI:lg[(@type='#{@lg_type}' or @type='triplet') and @n='#{previous_stanza_index}']", 'TEI' => 'http://www.tei-c.org/ns/1.0')

                xpath = 'TEI:l' + '[@n]'
                previous_stanza_lines = previous_stanza.xpath(xpath, 'TEI' => 'http://www.tei-c.org/ns/1.0')

                if previous_stanza_lines.nil?

                  raise NotImplementedError.new "Could not retrieve the previous sibling Element for #{xpath}"
                else

                  element['n'] = previous_stanza_lines.last['n'].to_i + 1
                end
              elsif not previous_element.has_attribute? 'n'

                raise NotImplementedError.new "The previous sibling Element for #{xpath} has no @n attribute"
              else

                element['n'] = previous_element['n'].to_i + 1
              end
            end
          end
        end
      end

      nota_bene_delta_map = {
        '«MDUL»' => { 'hi' => { 'rend' => 'underline' } },
        '«/DECORATOR»' => { 'ab' => { 'type' => 'typography' } },
        '«FN1·' => { 'note' => { 'rend' => 'foot' } },
      }

      # Ensure that all Nota Bene deltas have been cleaned
      ["//TEI:l/*", "//TEI:note/*"].each do |xpath|
      elements = @element.xpath(xpath, 'TEI' => 'http://www.tei-c.org/ns/1.0')

      elements.each do |nota_bene_element|

          # Handle unencoded indentation markup
          if /\|/.match nota_bene_element.content

            indent_count = nota_bene_element.content.count('|')

            if nota_bene_element.parent.key? 'rend'

              nota_bene_element.parent['rend'] = nota_bene_element.parent['rend'] + " indent(#{indent_count})"
            else

              nota_bene_element.parent['rend'] = "indent(#{indent_count})"
            end

            nota_bene_element.children.select { |element| element.text? }.map { |element| element.content = element.content.gsub(/\|/, '') }
          end

          # Handle unencoded stanza markup
          if /_/.match nota_bene_element.content

            nota_bene_element.children.select { |element| element.text? }.map { |element| element.content = element.content.gsub(/_/, '') }
          end

          # If this element is an unencoded Nota Bene delta...
          if /«.+»?/.match nota_bene_element.name

            nota_bene_delta = nota_bene_element.name

            raise NotImplementedError.new "Could not parse the delta #{nota_bene_element.name}" unless nota_bene_delta_map.has_key? nota_bene_delta
          
            corrected_name = nota_bene_delta_map[nota_bene_delta].keys.first
            corrected_element = Nokogiri::XML::Node.new corrected_name, @element.document

            # Add the attributes
            corrected_attribs = nota_bene_delta_map[nota_bene_delta][corrected_name]
            corrected_attribs.each_pair do |attrib_name, attrib_value|

              corrected_element[attrib_name] = attrib_value
            end

            # Override the added attributes with existing attributes
            nota_bene_element.attributes do |attrib_name, attrib_value|

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
          end

        end
      end
    end
  end
end
