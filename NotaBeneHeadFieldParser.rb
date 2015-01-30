

module SwiftPoemsProject

  class NotaBeneHeadFieldParser

    attr_reader :teiParser, :document, :footnote_index

    def initialize(teiParser, text, docTokens = nil, options = {})

      @teiParser = teiParser
      @text = text
      @document = teiParser.teiDocument
      @documentTokens = teiParser.documentTokens

      # SPP-156
      @footnote_index = options[:footnote_index] || 0
    end
  end
end
