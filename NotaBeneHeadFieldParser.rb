

module SwiftPoemsProject

  class NotaBeneHeadFieldParser

    attr_reader :teiParser, :document

    def initialize(teiParser, text, docTokens = nil)

      @teiParser = teiParser
      @text = text
      @document = teiParser.teiDocument
      @documentTokens = teiParser.documentTokens
    end
  end
end
