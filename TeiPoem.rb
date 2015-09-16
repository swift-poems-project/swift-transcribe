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

  class TeiLinkGroup

    def initialize(poem, type = 'notes')

      @poem = poem
      @type = type

      @element = Nokogiri::XML::Node.new 'linkGrp', @poem.element.document
      @poem.element.add_previous_sibling @element
      @element['type'] = @type
    end

    def add_link(source, target)

      link = Nokogiri::XML::Node.new 'link', @poem.element
      link['target'] = "#{source} #{target}"

      @element.add_child link
    end
  end

  class TeiPoem

    attr_reader :id, :element, :link_group, :stanzas

    def self.normalize(poem)

      poem = NotaBeneNormalizer::normalize poem
      
      NB_BLOCK_LITERAL_PATTERNS.each do |pattern|

        poem = poem.sub pattern, '«UNCLEAR»'
      end

      return poem
    end

    def initialize(poem, id, work_type, element, footnote_index = 0)

      @poem = poem
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

      @tokens = @poem.split /(?=«)|(?=[\.─\\a-z]»)|(?<=«FN1·)|(?<=»)|(?=om\.)|(?<=om\.)|(?=\\)|(?<=\\)|\n/

      @link_group = TeiLinkGroup.new self

      @stanzas = [ TeiStanza.new(self, @work_type, 1, { :footnote_index => @footnote_index }) ]
    end

    def parse

      # Classify our tokens
      @tokens.each do |initialToken|

        raise NotImplementedError, initialToken if initialToken if /──────»/.match initialToken
        
        # Extend the handling for poems by addressing cases in which "_" characters encode new paragraphs within footnotes
        
        # Create a new stanza
        stanza_tokens = initialToken.split(/_/)

        while stanza_tokens.length > 1
             
          # Ensure that every stanza is prepended with an empty <l>
          # SPP-213
          @stanzas.last.pushEmptyLine unless @stanzas.empty? or not @stanzas.last.opened_tags.empty?

          stanza_token = stanza_tokens.shift

          # This is where the additional empty line is created
          # This is also where empty @n attributes are created
          # @stanzas.last.push stanza_token

          if not @stanzas.last.opened_tags.last.nil? and
              /^«/.match( @stanzas.last.opened_tags.last.name )

            @stanzas.last.push_line_break stanza_token
          else

            # Append the new stanza to the poem body
            @stanzas << TeiStanza.new(self, @work_type, @stanzas.size + 1, {
                                        :opened_tags => @stanzas.last.opened_tags,
                                        :footnote_index => @stanzas.last.footnote_index
                                      })
          end
        end
        
        # Solution implemented for SPP-86
        #
        # @todo Refactor
        if initialToken.match /^[^«].+?»$/
             
          raise NotImplementedError, "Could not parse the following terminal «FN1· sequence: #{initialToken}"
        end

        @stanzas.last.push stanza_tokens.shift unless stanza_tokens.empty?
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

      xpath = "//TEI:lg[@type='#{@lg_type}']/TEI:l"
      l_elements = @element.xpath(xpath, 'TEI' => 'http://www.tei-c.org/ns/1.0')
    end

    # Retrieve numbered lines within all stanzas
    def stanza_lines(line_number = nil)

      if line_number.nil?

        xpath = "//TEI:lg[@type='#{@lg_type}']/TEI:l[@n]"
      else

        xpath = "//TEI:lg[@type='#{@lg_type}']/TEI:l[@n='#{line_number}']"
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
      
#      return if l_elements.empty?

      indices = l_elements.select { |element| not element.has_attribute? 'n' and not element.next_element.nil? }
      indices.each do |element|

        element['n'] = element.previous_element['n'].to_i + 1
      end

      # Reorder elements
      indices = l_elements.select { |element| element.has_attribute? 'n' }.map { |element| element['n'].to_i }
      sorted_indices = indices.sort
      valid_range = (sorted_indices.first..sorted_indices.last).to_a

      if sorted_indices.length > valid_range.length

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
          l_element['n'] = "#{index - 1}"

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
              # raise NotImplementedError.new "Multiple Elements found using #{xpath}\n#{@element.to_xml}"
              raise NotImplementedError.new "Multiple Elements found using #{xpath}"
            else
              
              element = elements.shift

              previous_element = element.previous_element

              if previous_element.nil?

                # Retrieve the previous stanza
                previous_stanza = element.parent.previous_element

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

      # expect(indices).to eq(valid_range.to_a)


#      puts @element.to_xml
#      exit(1)
    end
  end
end
