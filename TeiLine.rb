# -*- coding: utf-8 -*-

require_relative 'EditorialTag'

module SwiftPoemsProject

  include EditorialMarkup

   class TeiLine

     attr_reader :elem, :has_opened_tag, :opened_tag, :opened_tags, :footnote_index, :element

     def initialize(workType, stanza, options = {})

       @workType = workType
       @stanza = stanza

       # Refactor
       @has_opened_tag = options[:has_opened_tag] || false
       @opened_tags = options[:opened_tags] || []

       @editorial_tags = options[:editorial_tags] || []
       @substitution_tags = options[:substitution_tags] || []

       # Extending the Class in order to support footnote indexing
       # SPP-156
       @footnote_index = options[:footnote_index] || 0

       @number = options.fetch :number, 1
       @line_number_parsed = false

       @teiDocument = stanza.document

       # @lineElemName = @workType == POEM ? 'l' : 'p'
       @lineElemName = 'l'

       # Set the current leaf of the tree being constructed to be the root node itself
       # Legacy attribute
       @element = Nokogiri::XML::Node.new(@lineElemName, @teiDocument)
       @elem = @element
#       @elem['n'] = @number.to_s
#       mint_xml_id(@number.to_s)

       stanza.elem.add_child @elem

       # If there is an open tag...
       # if @has_opened_tag

       # If there are opened tags...
       elem = @elem

       # debugOutput = @opened_tags.map { |tag| tag.to_xml }
       # puts "Line added with the following opened tags: #{debugOutput}\n\n"

       if not @opened_tags.empty?

         # Work-around
         last_tag_name = @lineElemName

         @opened_tags.each do |opened_tag|

           # puts "Appending opened tag: #{opened_tag}"

           # @todo Refactor
           if last_tag_name == opened_tag.name

             elem.add_child opened_tag.children
           else

             # ...append the child tag and add an element
=begin
             opened_tag = Nokogiri::XML::Node.new(opened_tag.name, @teiDocument)
             elem = elem.add_child opened_tag
=end
             elem = elem.add_child opened_tag.element

             # Update the stanza
             # This duplicates tokens between lines, but does ensure that tags are passed between stanzas
             @stanza.opened_tags.unshift opened_tag

             # Append the opened tag 
             # @stanza.opened_tags.unshift opened_tag

             # @stanza.opened_tags.unshift elem.add_child(opened_tag)
             @current_leaf = opened_tag
           end

           last_tag_name = opened_tag.name
         end
       else

         @current_leaf = @elem
       end

       @tokens = []
     end

     def content
       @element.content
     end

     # Mint the unique line identifier
     #
     def mint_xml_id(line_number)

       @xml_id = "spp-#{@stanza.poem.id}-line-#{line_number}"

       # Ensure that the line ID hasn't already been minted
       line_element = @teiDocument.at_xpath("//tei:l[@xml:id='#{@xml_id}']", TEI_NS)
       if not line_element.nil?
         $stderr.puts "Warning: Could not mint the XML identifier for #{line_number}"
         $stderr.puts "#{line_element.to_xml}"
         exit(1)
         mint_xml_id("#{line_number}-alt")
       else
         @elem['xml:id'] = @xml_id
       end
     end

     def number(value = nil)

       return @elem['n'] if value.nil?

#       puts "Applying the poem number: #{value}"
#       puts @elem

       @elem['n'] = value

       # Update the xml:id value
       mint_xml_id @elem['n']
     end

     def number=(value)

       number(value)
     end

     def self.is_a_line?(node)
       return node.is_a?(Nokogiri::XML::Element) && ['l','p'].include?(node.name)
     end

     def self.is_numbered?(node)
       return node.is_a?(Nokogiri::XML::Element) && node.has_attribute?('n') && !node['n'].empty?
     end

     # Add this as a text node for the current line element
     def pushText(token)

       # Terminal condition for empty tokenized strings
       return if token.strip.empty?

       # Extracting indices is not necessary for Nota Bene Mode Codes
       # It is also not necessary if the @n element has already been set
       if not @current_leaf.is_a? NotaBeneDelta

         # @todo Refactor

         # Transform triplet indicators for the stanza
         if /\s3\}$/.match token

           @stanza.elem['type'] = 'triplet'
           # token = token.sub /\s3\}$/, ''
         end

         # Transform pipes into @rend values
         if /\|/.match token

           indentations = token.split(/\|/).select {|s| s.empty? }
           indentations.each do |indent|

             push_line_indent indent
           end

           token = token.gsub /\|+/, ''
         end
       end
       
       # Replace all Nota Bene deltas with UTF-8 compliant Nota Bene deltas
       NB_CHAR_TOKEN_MAP.each do |nbCharTokenPattern, utf8Char|
                   
         token = token.gsub(nbCharTokenPattern, utf8Char)
       end

       @current_leaf.add_child Nokogiri::XML::Text.new token, @teiDocument
     end

     def pushSingleToken(token)

       # Extended handling for "_" characters
       # SPP-240
       #
       if token == NB_EMPTY_LINE
         if @current_leaf.is_a? Nokogiri::XML::Element
           @current_leaf.add_next_sibling Nokogiri::XML::Node.new(@lineElemName, @teiDocument)
         end
       elsif NB_DELTA_FLUSH_TEI_MAP.has_key? token

         current_leaf = FlushDelta.new(token, @teiDocument, @current_leaf)
       elsif NB_DELTA_ATTRIB_TEI_MAP.has_key? token

         current_leaf = AttributeNotaBeneDelta.new(token, @teiDocument, @current_leaf)
       else

         single_tag = UnaryNotaBeneDelta.new(token, @teiDocument, @current_leaf)
       end
     end

     def pushInitialToken(token)

       @current_leaf = BinaryNotaBeneDelta.new(token, @teiDocument, @current_leaf)
       @has_opened_tag = true
       @opened_tag = @current_leaf

       # Add the opened tag for the stanza and line
       # @todo refactor
       @stanza.opened_tags.unshift @opened_tag
     end

     # Deprecated
     # @todo Remove
     #
     def close(token, opened_tag)

       while not @stanza.opened_tags.empty? and NB_MARKUP_TEI_MAP.has_key? opened_tag.name and NB_MARKUP_TEI_MAP[opened_tag.name].has_key? token

         # This reduces the total number of opened tags within the stanza
         closed_tag = @stanza.opened_tags.shift

         # Also, reduce the number of opened tags for this line
         # @todo refactor

         # Iterate through all of the markup and set the appropriate TEI attributes
         attribMap = NB_MARKUP_TEI_MAP[closed_tag.name][token].values[0]
         closed_tag[attribMap.keys[0]] = attribMap[attribMap.keys[0]]

         # One cannot resolve the tag name and attributes until both tags have been fully parsed
         closed_tag.name = NB_MARKUP_TEI_MAP[closed_tag.name][token].keys[0]
         
         # Continue iterating throught the opened tags for the stanza
         opened_tag = @stanza.opened_tags.first
       end

       return closed_tag
     end

     def closeStanza(token, opened_tag, closed_tag = nil)

       # For terminal tokens, ensure that both the current line and preceding lines are closed by it
       # Hence, iterate through all matching opened tags within the stanza
       #
       while not @stanza.opened_tags.empty? and NB_MARKUP_TEI_MAP.has_key? opened_tag.name and NB_MARKUP_TEI_MAP[opened_tag.name].has_key? token

         # This reduces the total number of opened tags within the stanza
         closed_tag = @stanza.opened_tags.shift

         # Also, reduce the number of opened tags for this line
         # @todo refactor
         @opened_tags.shift

         closed_tag.close(token)
         
         # Continue iterating throught the opened tags for the stanza
         opened_tag = @stanza.opened_tags.first
       end

       return closed_tag
     end

     def push_terminal_token(token, opened_tag)

       # This closes a footnote
       if /^«FN1/.match opened_tag.name and /»$/.match token

         if @current_leaf.is_a? NotaBeneDelta

           @current_leaf.close token
         end

         @stanza.opened_tags.shift
         @opened_tags.shift

         # Add an index for the footnote
         # SPP-156
         @footnote_index += 1
         @current_leaf['n'] = @footnote_index

         # Add more complexity for the footnotes
         # SPP-253
         footnote_xml_id = "spp-#{@stanza.poem.id}-footnote-#{@footnote_index}"
         @current_leaf['xml:id'] = footnote_xml_id

         target = "##{footnote_xml_id}"
         source = "##{@xml_id}"

         # Add an inline <ref> element
         ref = Nokogiri::XML::Node.new 'ref', @teiDocument
         ref.content = @footnote_index
         ref['target'] = target

         if @current_leaf.is_a? NotaBeneDelta

           @current_leaf.element.add_previous_sibling ref
         else

           @current_leaf.add_previous_sibling ref
         end
         
         # Add an element to <linkGrp>
         @stanza.poem.link_group.add_link target, source

         @current_leaf = @current_leaf.parent
         
       elsif token != '«MDNM»'

         # Throw an exception if this is not a "MDNM" Modecode
         # if opened_tag.name != '«FN1' # Redundant

         if @current_leaf.is_a? Nokogiri::XML::Element

           pushInitialToken(token)
         else

           # @todo Reimplement; Resolve these anomalous cases
           @current_leaf.close '«MDNM»'

           @stanza.opened_tags.shift
           @opened_tags.shift

           @current_leaf = @current_leaf.parent
           
           pushInitialToken(token)
         end
       else

         # First, retrieve last opened tag for the line
         # In all cases where there are opened tags on previous lines, there is an opened tag on the existing line
         #
         
         closed_tag = closeStanza(token, opened_tag)
         
         # Once all of the stanza elements have been closed, retrieve the last closed tag for the line
         @current_leaf = closed_tag.parent
         @has_opened_tag = !@opened_tags.empty?
       end
     end

     # Pushes a line break
     #
     # @param [String] the line break token
     # @return [Object] the current leaf node of the document tree (can be instances of Nokogiri::XML::Node or NotaBenaDelta)
     def push_line_break(line_break)

       line_break_elem = Nokogiri::XML::Node.new 'lb', @teiDocument
       @current_leaf.add_child line_break_elem
     end

     # Pushes a line indentation
     #
     # @param [String] the line indentation token
     # @return [Object] the current leaf node of the document tree (can be instances of Nokogiri::XML::Node or NotaBenaDelta)
     def push_line_indent(indent = '|')

       rend = @current_leaf['rend']
       m = /indent\((\d+)\)/.match rend

       if m

         indent = m[1].to_i + 1
         rend.gsub /indent\(#{m[1]}\)/, "indent(#{indent})"
       elsif rend

         @current_leaf['rend'] = @current_leaf['rend'] + ' indent(1)'
       else

         @current_leaf['rend'] = "indent(1)"
       end
     end

     # Pushes an editorial markup token
     #
     # @param token [String] the token string
     # @return [Object] the current leaf node of the document tree (can be instances of Nokogiri::XML::Node or NotaBenaDelta)
     def push_editorial(token)

       # If this is an editorial token...
       if EditorialMarkup::EDITORIAL_TOKENS.include? token

         # Closes the tag
         if not @editorial_tags.empty?

           editorial_tag = @editorial_tags.pop

           # Iterate through all child ('hi') tags
           editorial_tag.element.children.each do |child|

             child.remove if child.name == 'hi' and child.content.empty?
           end

           @current_leaf = editorial_tag.parent
         else # Open the tag

#           editorial_class = EDITORIAL_TOKEN_CLASSES[token]
#           editorial_tag = editorial_class.new token, @teiDocument, @current_leaf

           editorial_tag = EditorialMarkup::EditorialTag.new token, @teiDocument, @current_leaf

           @editorial_tags << editorial_tag
           @current_leaf.add_child editorial_tag.element
           @current_leaf = editorial_tag.element
         end
       else

         raise NotImplementedError
       end
     end
     
     # (Continue to) Parse a sequence of tokens structured within editorial markup
     #
     # @param [String] the token within the editorial markup delimiters
     # @return [String] the token (after it has been tranformed)
     def parse_editorial_text(token)

       editorial_tag = @editorial_tags.pop
       parent = editorial_tag.parent

       # Normalize the text
       token = token.gsub /^·/, ''
       token = token.gsub /·/, ' '

       return token if token.empty?

       case editorial_tag
       when EditorialMarkup::AddTag, EditorialMarkup::DelTag, EditorialMarkup::CaretAddTag

         # Extend the handling here for sequences of (potentially, unescaped) markup tokens
         if EditorialMarkup::EDITORIAL_TOKEN_CLASSES.has_key? token.strip

           klass = EditorialMarkup.const_get( EditorialMarkup::EDITORIAL_TOKEN_CLASSES[token.strip] )
           new_tag = klass.new token, @teiDocument, parent

           # For these cases, the @reason attribute is not specified within the sequence
#           editorial_tag.element.delete 'reason'
           editorial_tag = new_tag
         else

           if not editorial_tag.element.content.empty?
             editorial_tag.element.children.select { |node| node.text? }.first.content = token.strip
           else
             editorial_tag.element.content = token.strip
           end

           if not @current_leaf.is_a? NotaBeneDelta

             # Don't swap the ordering of the elements
             # @todo Refactor
             editorial_tag.element.delete 'reason'
             @editorial_tags << editorial_tag

             # Normalize the text
             token = ''

             return token
           else

             # editorial_tag.element.content = token
             @current_leaf = editorial_tag.element
           end
         end
       when EditorialMarkup::UnclearOverwritingTag

         editorial_tag.add_element.content = token
         token = ''
       when EditorialMarkup::AltReadingTag

         if not editorial_tag.rdg_u_element.content.empty?

           editorial_tag.rdg_v_element.content = token
         else
           editorial_tag.rdg_u_element.content = token
         end
         token = ''

         # Remove the @reason value
         editorial_tag.element.delete 'reason'

       # @todo Extend handling for information in relation to witnesses?
       when EditorialMarkup::InsertionOverwritingTag

         if @current_leaf.is_a? NotaBeneDelta

           editorial_tag.element.children[-2]['place'] = token
         else
           unclear_element = Nokogiri::XML::Node.new 'unclear', @teiDocument
           editorial_tag.del_element.add_child unclear_element

           add_element = Nokogiri::XML::Node.new 'add', @teiDocument
           add_element.content = token
           editorial_tag.element.add_child add_element
         end
       when EditorialMarkup::OverwritingTag

         if not editorial_tag.add_element.content.empty?

           editorial_tag.del_element.content = token
         else
           editorial_tag.add_element.content = token
         end
         token = ''
       when EditorialMarkup::SubstitutionTag

         if not editorial_tag.del_element.content.empty?

           editorial_tag.add_element.content = token
         else
           editorial_tag.del_element.content = token
         end

         token = ''
       when EditorialMarkup::EditorialTag

         if token.match(/^\s*blotted$/)

           token = token.strip
           editorial_tag.element['reason'] = token
           token = ''
         end

         # For more complex parsing of editorial token patterns
         # In these cases, the editorial markup keywords (e. g. \clad·[...]written·above·deleted·"drest"[...]\) cannot be separated from the marked up terms (e. g. written·above·deleted·"drest")
         content_tail = ''
         EditorialMarkup::EDITORIAL_TOKEN_PATTERNS.each do |editorial_token_pattern|

           if m = editorial_token_pattern.match( token.strip )

             token = m[1]
             content_tail = m[2]
           end
         end

         # Type the editorial markup class
         # If no class has been defined, it remains encoded as <unclear>
         if EditorialMarkup::EDITORIAL_TOKEN_CLASSES.has_key? token.strip

           editorial_tag.element.remove
           editorial_class = EditorialMarkup.const_get( EditorialMarkup::EDITORIAL_TOKEN_CLASSES[token.strip] )

           content = editorial_tag.element.content
           reason = editorial_tag.element['reason']

           editorial_tag = editorial_class.new token, @teiDocument, parent

           # Type-based handling must be undertaken here
           # It may be the case that this is the last substring before the markup is closed
           # As such, certain elements of the tag must be restructured
           #
           case editorial_tag
           when EditorialMarkup::UnclearOverwritingTag

             if not content_tail.empty?
               editorial_tag.add_element.content = content_tail.strip
             elsif not content.empty?
               editorial_tag.add_element.content = content.strip
             else
               unclear_element = Nokogiri::XML::Node.new 'unclear', @teiDocument
               editorial_tag.add_element.add_child unclear_element
             end
           when EditorialMarkup::AltReadingTag

             editorial_tag.rdg_u_element.content = content.strip
             editorial_tag.rdg_v_element.content = content_tail.strip
           when EditorialMarkup::OverwritingTag

             editorial_tag.add_element.content = content.strip
             editorial_tag.del_element.content = content_tail.strip
           when EditorialMarkup::SubstitutionTag

             editorial_tag.del_element.content = content.strip
           end
         elsif EditorialMarkup::EDITORIAL_TOKEN_REASONS.include? token.strip

           token = token.strip
           editorial_tag.element['reason'] = token
         else

           editorial_tag.element.content += token
           token = ''
         end
       end

       @editorial_tags << editorial_tag
       parent.add_child editorial_tag.element

       # Typically, the contents of a Nota Bene Delta within editorial markup contains a value appropriate for the @reason attribute
       if @current_leaf.is_a? NotaBeneDelta

         case editorial_tag
         when EditorialMarkup::InsertionOverwritingTag

           token = ''
           @current_leaf = editorial_tag.element
         else

           # Need to close the tag, remove it, and add the value as a "reason"
           editorial_tag.parse_reason token.strip
           token = ''
         end
       else

         # Normalize the text
         token = ''
         @current_leaf = editorial_tag.element
       end

       token
     end

     # Parses text for a <tei:subst> Element
     #
     # @param [String] the token of the substituted text
     # @return the token of the substituted text
     def parse_substitution_text(token)

       substitution_tag = @substitution_tags.pop
       @editorial_tags.pop

       substitution_tag.content = token
       token
     end

     def push(token)

       # puts "Appending the following token to the line: #{token}"

       # If there is an opened tag...

       # First, retrieve last opened tag for the line
       # In all cases where there are opened tags on previous lines, there is an opened tag on the existing line
       #
       # opened_tag = @opened_tags.first
       opened_tag = @stanza.opened_tags.first

       # Deprecating ternary token parsing
       # if opened_tag and NB_TERNARY_TOKEN_TEI_MAP.has_key? opened_tag.name and NB_TERNARY_TOKEN_TEI_MAP[opened_tag.name][:secondary].has_key? token

       # raise NotImplementedError.new "Attempting to parse tokens as 'ternary tokens'"
       # pushSecondTernaryToken token, opened_tag

       # debugOutput = @stanza.opened_tags.map {|tag| tag.to_xml }
       # puts "Opened stanza tags2: #{debugOutput}\n\n"

       # Check to see if this is a terminal token
       if opened_tag and NB_MARKUP_TEI_MAP.has_key? opened_tag.name and NB_MARKUP_TEI_MAP[opened_tag.name].has_key? token

         push_terminal_token token, opened_tag
         #
         # If there isn't an opened tag, but the current token appears to be a terminal token, raise an exception
         #
       elsif NB_MARKUP_TEI_MAP.has_key? @current_leaf.name and NB_MARKUP_TEI_MAP[@current_leaf.name].has_key? token

         raise NotImplementedError, "Failed to opened a tag closed by #{token}: #{@current_leaf.to_xml}"
         
         # If this is an initial token, open a new tag
         #
         # @todo Refactor
       elsif NB_MARKUP_TEI_MAP.has_key? token

         pushInitialToken token

       elsif NB_SINGLE_TOKEN_TEI_MAP.has_key? token

         pushSingleToken token

       elsif EditorialMarkup::EDITORIAL_TOKENS.include? token # This opens the parsing of editorial tokens

         push_editorial token
       else

         # Terminal tokens are not being properly parsed
         # e. g. previous line had a token MDUL, terminal token MDNM present in the following
         # MDNM was not identified as a token

         # @current_leaf needs to be updated

         raise NotImplementedError, "Failed to parse the following as a token: #{token}" if /«/.match token

         # Type the EditorialTag based upon the token
         if not @editorial_tags.empty?

           token = parse_editorial_text token
         end

         pushText token

         raise NotImplementedError, "Failure to close a tag likely detected: #{@teiDocument.to_xml}" if @opened_tags.length > 16
       end

       # Return the line number

       return @elem['n'].to_i
       
     end
   end
 end
