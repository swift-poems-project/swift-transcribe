

module SwiftPoemsProject

  class NotaBeneHeadFieldParser

    attr_reader :teiParser, :document, :footnote_index, :element, :poem

    def initialize(teiParser, id, text, docTokens = nil, options = {})

      @teiParser = teiParser
      @poem = teiParser.poem

      @id = id
      @text = text

      @document = @teiParser.teiDocument
      @documentTokens = @teiParser.documentTokens
      @element = @teiParser.headerElement

      # SPP-156
      @footnote_index = options[:footnote_index] || 0
    end
  end
end
