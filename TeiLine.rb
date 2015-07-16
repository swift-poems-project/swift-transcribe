# -*- coding: utf-8 -*-

module SwiftPoemsProject

   class TeiLine

     attr_reader :elem, :has_opened_tag, :opened_tag, :opened_tags, :footnote_index

     def initialize(workType, stanza, options = {})

       @workType = workType
       @stanza = stanza

       # Refactor
       @has_opened_tag = options[:has_opened_tag] || false
       @opened_tags = options[:opened_tags] || []

       # Extending the Class in order to support footnote indexing
       # SPP-156
       @footnote_index = options[:footnote_index] || 0

       # @teiDocument = teiDocument
       @teiDocument = stanza.document

       @lineElemName = @workType == POEM ? 'l' : 'p'

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

             # puts "TRACE: #{opened_tag.children}"
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
         poem_id_match = /([0-9A-Z]{8})   /.match(token) if not poem_id_match

         # Raise an exception if the transcript identifier cannot be parsed
         raise TeiPoemIdError.new "Could not extract the Poem ID from #{token}" unless poem_id_match

         poem_id = poem_id_match.to_s.strip
         raise NotImplementedError.new if poem_id.empty?

         @elem['n'] = poem_id
         token = token.sub poem_id_match[0], ''

         # Transform triplet indicators for the stanza
         if /\s3\}$/.match token

           @stanza.elem['type'] = 'triplet'
           token = token.sub /\s3\}$/, ''
         end

         # Transform pipes into @rend values
         if /\|/.match token

           if @current_leaf === @elem

=begin
           token_segments = token.split /\|/

           if (token_segments.length == 1 and not /\|/.match token_segments.first) or token_segments.empty?

             indentValue = 1
           else

             indentValue = token_segments.size - 1
           end

           raise NotImplementedError.new "Could not properly parse the indentation characters within: #{token} (#{token_segments.to_s})" if indentValue < 1
           
           @current_leaf['rend'] = 'indent(' + indentValue.to_s + ')'
           token = token.sub /\|+/, ''
=end

             indentations = token.split(/\|/).select {|s| s.empty? }
             indentations.each do |indent|

               push_line_indent indent
             end

             token = token.sub /\|+/, ''
           else

             # Work-around
             # Resolves SPP-146
             indentations = token.split(/\|/).select {|s| s.empty? }
             indentations.each do |indent|

               push_line_indent indent
             end

             token = token.sub /\|+/, ''
           end
         end
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

     def pushTermTernaryToken(token, opened_tag)

       # The initial tag for the ternary sequence
       opened_init_tag = @stanza.opened_tags[1]

       while not @stanza.opened_tags.empty? and NB_TERNARY_TOKEN_TEI_MAP.has_key? opened_init_tag.name and NB_TERNARY_TOKEN_TEI_MAP[opened_init_tag][:secondary].has_key? opened_tag.name and NB_TERNARY_TOKEN_TEI_MAP[opened_init_tag][:terminal].has_key? token

         raise NotImplementedError, "Terminal ternary token for #{token}"

         # This reduces the total number of opened tags within the stanza
         closed_tag = @stanza.opened_tags.shift

         # Also, reduce the number of opened tags for this line
         # @todo refactor
         @opened_tags.shift

         # logger.debug "Closing tag: #{closed_tag.name}..."

         # Iterate through all of the markup and set the appropriate TEI attributes
         attribMap = NB_MARKUP_TEI_MAP[closed_tag.name][token].values[0]
         closed_tag[attribMap.keys[0]] = attribMap[attribMap.keys[0]]

         # One cannot resolve the tag name and attributes until both tags have been fully parsed
         closed_tag.name = NB_MARKUP_TEI_MAP[closed_tag.name][token].keys[0]
         
         # Continue iterating throught the opened tags for the stanza
         opened_tag = @stanza.opened_tags.first
       end

       # Once all of the stanza elements have been closed, retrieve the last closed tag for the line
       @current_leaf = closed_tag.parent

       @has_opened_tag = !@opened_tags.empty?
     end

     def pushSecondTernaryToken(token, opened_tag)
       
       closed_tag = @stanza.opened_tags.shift
       # closed_tag = @stanza.opened_tags.first

       # Also, reduce the number of opened tags for this line
       # @todo refactor
       @opened_tags.shift

       # attribMap = NB_MARKUP_TEI_MAP[closed_tag.name][token].values[0]
       # closed_tag[attribMap.keys[0]] = attribMap[attribMap.keys[0]]
       attribMap = NB_TERNARY_TOKEN_TEI_MAP[closed_tag.name][:secondary][token].values[0]
       closed_tag[attribMap.keys[0]] = attribMap[attribMap.keys[0]]

       # One cannot resolve the tag name and attributes until both tags have been fully parsed
       # closed_tag.name = NB_MARKUP_TEI_MAP[closed_tag.name][token].keys[0]
       closed_tag.name = NB_TERNARY_TOKEN_TEI_MAP[closed_tag.name][:secondary][token].keys[0]

       @current_leaf = @current_leaf.next = Nokogiri::XML::Node.new token, @teiDocument
       @has_opened_tag = true
       @opened_tag = @current_leaf

       @stanza.opened_tags.unshift @opened_tag
       @opened_tags.unshift @opened_tag
     end

     def pushInitialToken(token)

=begin
       @current_leaf = @current_leaf.add_child Nokogiri::XML::Node.new token, @teiDocument
       @has_opened_tag = true
       @opened_tag = @current_leaf
=end
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

       if /^«FN1/.match opened_tag.name and /»$/.match token

         @current_leaf.close token

         @stanza.opened_tags.shift
         @opened_tags.shift

         # Add an index for the footnote
         # SPP-156
         @footnote_index += 1
         @current_leaf['n'] = @footnote_index 

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

           # raise NotImplementedError.new "Cannot close the opened Modecode #{opened_tag.name} with the token: #{token}"
         #else

         #  raise NotImplementedError.new "Attempting to parse the footnote #{opened_tag.name} closed with the token #{token} as a standard line"
         #end
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
       else

         # puts NB_MARKUP_TEI_MAP.has_key? @opened_tag.name if @opened_tag
         # puts NB_MARKUP_TEI_MAP[@opened_tag.name].has_key? token.strip if @opened_tag and NB_MARKUP_TEI_MAP.has_key? @opened_tag.name
         # puts NB_MARKUP_TEI_MAP[@opened_tag.name].keys if @opened_tag and NB_MARKUP_TEI_MAP.has_key? @opened_tag.name

         # Terminal tokens are not being properly parsed
         # e. g. previous line had a token MDUL, terminal token MDNM present in the following
         # MDNM was not identified as a token

         # @current_leaf needs to be updated

         raise NotImplementedError, "Failed to parse the following as a token: #{token}" if /«/.match token

         # logger.debug "Appending text to the line: #{token}"
         
         pushText token

         debugOutput = @opened_tags.map { |tag| tag.name }
         # puts "Updated tags for the line: #{debugOutput}"

         raise NotImplementedError, "Failure to close a tag likely detected: #{@teiDocument.to_xml}" if @opened_tags.length > 16
       end
     end
   end
 end
