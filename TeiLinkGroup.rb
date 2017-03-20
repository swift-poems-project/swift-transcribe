# -*- coding: utf-8 -*-

module SwiftPoemsProject

  class TeiLinkGroup

    def initialize(parent_element, type = 'notes')

      @parent_element = parent_element
      @type = type

      @element = Nokogiri::XML::Node.new 'linkGrp', @parent_element.document
      @parent_element.add_previous_sibling @element
      @element['type'] = @type
    end

    def add_link(source, target)

      link = Nokogiri::XML::Node.new 'link', @parent_element
      link['target'] = "#{source} #{target}"

      @element.add_child link
    end
  end
end
