

module SwiftPoemsProject

  class NotaBeneHeadFieldParser

    attr_reader :transcript

    # Legacy attributes
    attr_reader :teiParser, :document, :footnote_index, :element, :poem

    def initialize(transcript, id, text, docTokens = nil, options = {})

      @transcript = transcript
      @teiParser = @transcript

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
