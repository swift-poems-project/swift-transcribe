# -*- coding: utf-8 -*-

require_relative 'EditorialTag'

module SwiftPoemsProject

  include EditorialMarkup

   class TeiLine

     attr_reader :elem, :has_opened_tag, :opened_tag, :opened_tags, :footnote_index

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

       @teiDocument = stanza.document

       # @lineElemName = @workType == POEM ? 'l' : 'p'
       @lineElemName = 'l'

       # Set the current leaf of the tree being constructed to be the root node itself
       @elem = Nokogiri::XML::Node.new(@lineElemName, @teiDocument)
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

     # Mint the unique line identifier
     #
     def mint_xml_id(line_number)

       @xml_id = "spp-#{@stanza.poem.id}-line-#{line_number}"
       @elem['xml:id'] = @xml_id
     end

     def number(value)

       @elem['n'] = value

       # Update the xml:id value
       mint_xml_id @elem['n']
     end

     def number=(value)

       number(value)
     end

     # Add this as a text node for the current line element
     def pushText(token)

       # Terminal condition for empty tokenized strings
       return if token.strip.empty?

       # Extracting indices is not necessary for Nota Bene Mode Codes
       # It is also not necessary if the @n element has already been set
       if not @current_leaf.is_a? NotaBeneDelta

         # @todo Refactor
         if not(@current_leaf.is_a? Nokogiri::XML::Element and @current_leaf.has_attribute? 'n' and not @current_leaf['n'].empty?)

           # Remove the 8 character identifier from the beginning of the line
           poem_id_match = /\s*(\d+)\s+/.match token

           poem_id_match = /([0-9A-Z\!\-]{8})   /.match(token) if not poem_id_match
           poem_id_match = /([0-9A-Z]{8})   /.match(token) if not poem_id_match # Isn't this redundant?

           # Raise an exception if the transcript identifier cannot be parsed
           if poem_id_match

             poem_id = poem_id_match.to_s.strip

             #if //.match token
             #  puts "TRACE: #{token}"
             #  puts "TRACE: #{poem_id}"
             #end

             # @todo Implement using TeiPoemIdError
             raise NotImplementedError.new "Could not extract the Poem ID from #{token}" if poem_id.empty?

             # @elem['n'] = poem_id
             number(poem_id)

             token = token.sub poem_id_match[0], ''
           elsif @elem.has_attribute? 'rend' # This handles cases in which the previous token contained a line number and a unary Nota Bene Delta

             if @stanza.lines.length == 1

               if @stanza.poem.stanzas.length == 1

                 number(1)
               else

                 number( @stanza.poem.stanzas[-2].lines[-2].elem['n'].to_i + 1 )
               end
             else

               # @elem['n'] = @stanza.lines[-2].elem['n'].to_i + 1
               number( @stanza.lines[-2].elem['n'].to_i + 1)
             end
           elsif not @elem.has_attribute? 'n'

             # @elem['n'] = @stanza.lines[-2].elem['n'].to_i + 1 # Which cases are handled here?
             number( @stanza.lines[-2].elem['n'].to_i + 1) # Which cases are handled here?
           end
         end

         # Transform triplet indicators for the stanza
         if /\s3\}$/.match token

           @stanza.elem['type'] = 'triplet'
           token = token.sub /\s3\}$/, ''
         end

         # Transform pipes into @rend values
         if /\|/.match token
           
           indentations = token.split(/\|/).select {|s| s.empty? }
           indentations.each do |indent|

             push_line_indent indent
           end

           token = token.sub /\|+/, ''
         end
       end
       
       # Replace all Nota Bene deltas with UTF-8 compliant Nota Bene deltas
       NB_CHAR_TOKEN_MAP.each do |nbCharTokenPattern, utf8Char|
                   
         token = token.gsub(nbCharTokenPattern, utf8Char)
       end

       @current_leaf.add_child Nokogiri::XML::Text.new token, @teiDocument
     end

     def pushSingleToken(token)

       if NB_DELTA_FLUSH_TEI_MAP.has_key? token

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

       # puts "Opening a tag: #{@opened_tag.parent}"

       # @stanza.opened_tags << @opened_tag
       
       # Add the opened tag for the stanza and line
       # @todo refactor
       @stanza.opened_tags.unshift @opened_tag
       # @opened_tags.unshift @opened_tag

       # If the tag is not specified within the markup map, raise an exception
       #
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
         # @opened_tags.shift

         # closed_tag = @opened_tags.shift
         # @stanza.opened_tags.shift

         # puts "Closing tag for line: #{closed_tag.name}..."

         # Iterate through all of the markup and set the appropriate TEI attributes
         attribMap = NB_MARKUP_TEI_MAP[closed_tag.name][token].values[0]
         closed_tag[attribMap.keys[0]] = attribMap[attribMap.keys[0]]

         # One cannot resolve the tag name and attributes until both tags have been fully parsed
         closed_tag.name = NB_MARKUP_TEI_MAP[closed_tag.name][token].keys[0]
         
         # logger.debug "Closed tag: #{closed_tag.name}"
         # logger.debug "Updated element: #{closed_tag.to_xml}"

         # @current_leaf = opened_tag.parent
         # @opened_tag = @stanza.opened_tags.first
         # @has_opened_tag = false
             
         # Continue iterating throught the opened tags for the stanza
         opened_tag = @stanza.opened_tags.first
       end

       return closed_tag
     end

     def closeStanza(token, opened_tag, closed_tag = nil)

=begin
       debugOutput = @stanza.opened_tags.map {|tag| tag.name }
       puts "Terminating a sequence #{debugOutput}"
       puts @stanza.elem.to_xml
=end

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
         
         # logger.debug "Closed tag: #{closed_tag.name}"
         # logger.debug "Updated element: #{closed_tag.to_xml}"

         # @current_leaf = opened_tag.parent
         # @opened_tag = @stanza.opened_tags.first
         # @has_opened_tag = false
             
         # Continue iterating throught the opened tags for the stanza
         opened_tag = @stanza.opened_tags.first
       end

       return closed_tag
     end

     def pushTerminalToken(token, opened_tag)

       # This closes a footnote
       if /^«FN1/.match opened_tag.name and /»$/.match token

         @current_leaf.close token

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
         @current_leaf.element.add_previous_sibling ref
         
         # Add an element to <linkGrp>
         @stanza.poem.link_group.add_link target, source

         @current_leaf = @current_leaf.parent
         
       elsif token != '«MDNM»'

         # Throw an exception if this is not a "MDNM" Modecode
         # if opened_tag.name != '«FN1' # Redundant

         # @todo Reimplement; Resolve these anomalous cases
         @current_leaf.close '«MDNM»'

         @stanza.opened_tags.shift
         @opened_tags.shift

         @current_leaf = @current_leaf.parent
           
         pushInitialToken(token)
       else

         # First, retrieve last opened tag for the line
         # In all cases where there are opened tags on previous lines, there is an opened tag on the existing line
         #
         
         # puts "Current opened tags in the stanza: #{@stanza.opened_tags}" # @todo Refactor
         
         # @stanza.opened_tags << @opened_tag
         
         # @stanza.opened_tags = []
         # @has_opened_tag = false
         # @current_leaf = @stanza.opened_tags.last.parent
         
         # More iterative approach
         
         # opened_tag = @stanza.opened_tags.shift
         
         # closed_tag = close(token, opened_tag)
         # closeStanza(token, opened_tag, closed_tag)
         closed_tag = closeStanza(token, opened_tag)
         
         # puts @teiDocument
         # puts closed_tag
         
         # Once all of the stanza elements have been closed, retrieve the last closed tag for the line
         
         @current_leaf = closed_tag.parent
         # @opened_tag = @stanza.opened_tags.first
         
         # @has_opened_tag = false
         @has_opened_tag = !@opened_tags.empty?
         
       end
     end

     def push_line_break(line_break)

       line_break_elem = Nokogiri::XML::Node.new 'lb', @teiDocument
       @current_leaf.add_child line_break_elem
     end

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

     # \«MDUL»crossed·out«MDNM»·neithther\
     # \«MDUL»overwritten«MDNM»·y\
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

     def parse_substitution_text(token)

       substitution_tag = @substitution_tags.pop
       @editorial_tags.pop

       substitution_tag.content = token
       token
     end

     # Type the EditorialTag based upon the text content
     def parse_editorial_text(token)

       editorial_tag = @editorial_tags.pop
       parent = editorial_tag.parent

       if editorial_tag.is_a? EditorialMarkup::AddTag or editorial_tag.is_a? EditorialMarkup::DelTag

         token = token.gsub /·/, ''
         editorial_tag.element.content = token
       elsif editorial_tag.is_a? EditorialMarkup::SubstitutionTag

         # Normalize the text
         token = token.gsub /^·/, ''

         editorial_tag.del_element.content = token
         token = ''
       elsif editorial_tag.is_a? EditorialMarkup::EditorialTag

         # Clean the token
         token = token.gsub /·/, ' '

         if token.match(/^\s*blotted$/)

           token = token.strip
           editorial_tag.element['reason'] = token
           token = ''
         end

         if EditorialMarkup::EDITORIAL_TOKEN_CLASSES.has_key? token

           editorial_tag.element.remove
           editorial_class = EditorialMarkup.const_get( EditorialMarkup::EDITORIAL_TOKEN_CLASSES[token] )

           content = editorial_tag.element.content
           reason = editorial_tag.element['reason']

           editorial_tag = editorial_class.new token, @teiDocument, parent

           if editorial_tag.is_a? EditorialMarkup::BlotTag

             editorial_tag.element.content = reason + content
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

       if @current_leaf.is_a? NotaBeneDelta

#         editorial_tag.element.add_child @current_leaf.element

         # Need to close the tag, remove it, and add the value as a "reason"
         editorial_tag.parse_reason token
         token = ''
       else

         # Normalize the text
         #token = token.gsub /^·/, ''
         token = ''

         # puts token

         @current_leaf = editorial_tag.element
       end

       token
     end

     def push(token)
       
#       puts "Appending the following token to the line: #{token}"

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

         pushTerminalToken token, opened_tag
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

       elsif EditorialMarkup::EDITORIAL_TOKENS.include? token

         push_editorial token
       else

         # puts NB_MARKUP_TEI_MAP.has_key? @opened_tag.name if @opened_tag
         # puts NB_MARKUP_TEI_MAP[@opened_tag.name].has_key? token.strip if @opened_tag and NB_MARKUP_TEI_MAP.has_key? @opened_tag.name
         # puts NB_MARKUP_TEI_MAP[@opened_tag.name].keys if @opened_tag and NB_MARKUP_TEI_MAP.has_key? @opened_tag.name

         # Terminal tokens are not being properly parsed
         # e. g. previous line had a token MDUL, terminal token MDNM present in the following
         # MDNM was not identified as a token

         # @current_leaf needs to be updated

         raise NotImplementedError, "Failed to parse the following as a token: #{token}" if /«/.match token

         # Parse the substitution
         if not @substitution_tags.empty?

#           token = parse_substitution_text token
         end

         # Type the EditorialTag based upon the token
         if not @editorial_tags.empty?

           token = parse_editorial_text token
         end

         # puts "Appending text to the line: '#{token}'"
         
         pushText token

         debugOutput = @opened_tags.map { |tag| tag.name }
         # puts "Updated tags for the line: #{debugOutput}"

         raise NotImplementedError, "Failure to close a tag likely detected: #{@teiDocument.to_xml}" if @opened_tags.length > 16
       end
     end
   end
 end
