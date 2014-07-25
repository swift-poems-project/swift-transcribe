# -*- coding: utf-8 -*-

module SwiftPoemsProject
   class TeiLine

     attr_reader :elem, :has_opened_tag, :opened_tag, :opened_tags

     def initialize(workType, stanza, options = {})

       @workType = workType
       @stanza = stanza

       # Refactor
       @has_opened_tag = options[:has_opened_tag] || false
       @opened_tags = options[:opened_tags] || []

       # @opened_tag ||= options[:opened_tag]

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

       if not @opened_tags.empty?

         @opened_tags.each do |opened_tag|

           # ...append the child tag and add an element
           opened_tag = Nokogiri::XML::Node.new(opened_tag.name, @teiDocument)
           elem = elem.add_child opened_tag

           # Update the stanza
           @stanza.opened_tags.unshift opened_tag

           @current_leaf = opened_tag
         end
       else

         @current_leaf = @elem
       end

       @tokens = []
     end

     # Add this as a text node for the current line element
     def pushText(token)

       # Remove the 8 character identifier from the beginning of the line
       indexMatch = /\s{3}(\d+)\s{2}/.match token
       if indexMatch

         @elem['n'] = indexMatch.to_s.strip

         # token = token.sub /[!#\$A-Z0-9]{8}\s{3}(\d+)\s{2}_?/, ''
         token = token.sub /\s{3}(\d+)\s{2}_?/, ''
       end

       # Transform triplet indicators for the stanza
       if /\s3\}$/.match token

         @stanza.elem['type'] = 'triplet'
         token = token.sub /\s3\}$/, ''
       end

=begin
new stanza token: «MDUL»
new stanza token: Upon the Water cast thy Bread,
line text: Upon the Water cast thy Bread,
new stanza token: 250-0201   142  |And after many Days thou'lt find it
new line token:    142  |And after many Days thou'lt find it
line text:    142  |And after many Days thou'lt find it
new stanza token: «MDNM»
new line token: «MDNM»
line text: «MDNM»
=end

       # Transform pipes into @rend values
       if /\|/.match token and @current_leaf === @elem

         indentValue = (token.split /\|/).size - 1

         @current_leaf['rend'] = 'indent(' + indentValue.to_s + ')'
         token = token.sub /\|/, ''
       end

       # Replace all Nota Bene deltas with UTF-8 compliant Nota Bene deltas
       NB_CHAR_TOKEN_MAP.each do |nbCharTokenPattern, utf8Char|
                   
         token = token.gsub(nbCharTokenPattern, utf8Char)
       end

       @current_leaf.add_child Nokogiri::XML::Text.new token, @teiDocument
     end

     def pushInitialToken(token)

       puts "Opening tag: #{token}"

       @current_leaf = @current_leaf.add_child Nokogiri::XML::Node.new token, @teiDocument
       @has_opened_tag = true
       @opened_tag = @current_leaf

       # @stanza.opened_tags << @opened_tag
       
       # Add the opened tag for the stanza and line
       # @todo refactor
       @stanza.opened_tags.unshift @opened_tag
       @opened_tags.unshift @opened_tag
       
       # If the tag is not specified within the markup map, raise an exception
       #
     end

     def pushTerminalToken(token, opened_tag)

       # First, retrieve last opened tag for the line
       # In all cases where there are opened tags on previous lines, there is an opened tag on the existing line
       #

       puts "Current opened tags in the stanza: #{@stanza.opened_tags}" # @todo Refactor

         # @stanza.opened_tags << @opened_tag
=begin
         @stanza.opened_tags.each do |opened_tag|

           puts "Iterating for #{opened_tag.name}"

           # Iterate through all of the markup and set the appropriate TEI attributes
           attribMap = NB_MARKUP_TEI_MAP[opened_tag.name][token].values[0]
           opened_tag[attribMap.keys[0]] = attribMap[attribMap.keys[0]]

           # One cannot resolve the tag name and attributes until both tags have been fully parsed
           opened_tag.name = NB_MARKUP_TEI_MAP[opened_tag.name][token].keys[0]

           puts "Closed tag: #{opened_tag.name}"
         end
=end

         # @stanza.opened_tags = []
         # @has_opened_tag = false
         # @current_leaf = @stanza.opened_tags.last.parent

         # More iterative approach

         # opened_tag = @stanza.opened_tags.shift

       # For terminal tokens, ensure that both the current line and preceding lines are closed by it
       # Hence, iterate through all matching opened tags within the stanza
       #
       while not @stanza.opened_tags.empty? and NB_MARKUP_TEI_MAP.has_key? opened_tag.name and NB_MARKUP_TEI_MAP[opened_tag.name].has_key? token

         # This reduces the total number of opened tags within the stanza
         closed_tag = @stanza.opened_tags.shift

         # Also, reduce the number of opened tags for this line
         # @todo refactor
         @opened_tags.shift

         puts "Closing tag: #{closed_tag.name}..."

         # Iterate through all of the markup and set the appropriate TEI attributes
         attribMap = NB_MARKUP_TEI_MAP[closed_tag.name][token].values[0]
         closed_tag[attribMap.keys[0]] = attribMap[attribMap.keys[0]]

         # One cannot resolve the tag name and attributes until both tags have been fully parsed
         closed_tag.name = NB_MARKUP_TEI_MAP[closed_tag.name][token].keys[0]
         
         puts "Closed tag: #{closed_tag.name}"
         puts "Updated element: #{closed_tag.to_xml}"

         # @current_leaf = opened_tag.parent
         # @opened_tag = @stanza.opened_tags.first
         # @has_opened_tag = false
             
         # Continue iterating throught the opened tags for the stanza
         opened_tag = @stanza.opened_tags.first
       end

       # Once all of the stanza elements have been closed, retrieve the last closed tag for the line

       @current_leaf = closed_tag.parent
       # @opened_tag = @stanza.opened_tags.first

       # @has_opened_tag = false
       @has_opened_tag = !@opened_tags.empty?
     end

     def push(token)

       # If there is an opened tag...

       # First, retrieve last opened tag for the line
       # In all cases where there are opened tags on previous lines, there is an opened tag on the existing line
       #
       opened_tag = @opened_tags.first

       puts "Does this line have an opened tag? #{!opened_tag.nil?}"
       puts "Name of the opened tag: #{opened_tag.name}" if opened_tag

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
       else

=begin
         raise NotImplementedError, "Failed to open the tag #{token}"

         # Add a new child node to the current leaf
         # Temporarily use the token itself as a tagname
         # @todo Refactor
         @current_leaf = @current_leaf.add_child Nokogiri::XML::Node.new token, @teiDocument
=end

       # puts NB_MARKUP_TEI_MAP.has_key? @opened_tag.name if @opened_tag
       # puts NB_MARKUP_TEI_MAP[@opened_tag.name].has_key? token.strip if @opened_tag and NB_MARKUP_TEI_MAP.has_key? @opened_tag.name
       # puts NB_MARKUP_TEI_MAP[@opened_tag.name].keys if @opened_tag and NB_MARKUP_TEI_MAP.has_key? @opened_tag.name

=begin
       if @has_opened_tag and NB_MARKUP_TEI_MAP.has_key? @opened_tag.name and (NB_MARKUP_TEI_MAP[@opened_tag.name].has_key? token or NB_MARKUP_TEI_MAP[@opened_tag.name].has_key? token.strip)

         puts "Closing the tag with the terminal token: #{token}"

         pushToken token
       elsif NB_MARKUP_TEI_MAP.has_key? token or (NB_MARKUP_TEI_MAP.has_key? @current_leaf.name and NB_MARKUP_TEI_MAP[@current_leaf.name].has_key? token)

         puts "Appending an initial Nota Bene token: #{token}"

         pushToken token
       else
=end

         # Terminal tokens are not being properly parsed
         # e. g. previous line had a token MDUL, terminal token MDNM present in the following
         # MDNM was not identified as a token

         # @current_leaf needs to be updated

         raise NotImplementedError, "Failed to parse the following as a token: #{token}" if /«/.match token

         puts "Appending text to the line: #{token}"
         
         pushText token
       end
     end
   end
 end
