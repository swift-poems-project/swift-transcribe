# -*- coding: utf-8 -*-

require_relative 'NotaBeneHeadFieldParser'

module SwiftPoemsProject

  class NotaBeneHeadnoteParser < NotaBeneHeadFieldParser

    attr_accessor :footnote_index

    def initialize(teiParser, id, text, docTokens = nil, cleanModeCodes = true, options = {})

      super(teiParser, id, text, docTokens, options)

      # Note: This assumes that HN fields consistently begin with an index of 1 and increment solely by a value of 1
      @heads = TeiPoemHeads.new @teiParser.poemElem, @id, '1', { :footnote_index => @footnote_index }
      @cleanModeCodes = cleanModeCodes
    end

    def clean(line)

      line = line.gsub /#{Regexp.escape("HN10 I should be very sorry to offend the «MDUL»Dean«MDNM», although I am a perfect Stranger to his «MDUL»Person«MDNM»: But, since the «MDUL»Poem«MDNM» will infallibly be soon printed, either «MDUL»here«MDNM», or in «MDUL»Dublin«MDNM», I take myself to have the best «MDUL»Title«MDNM» to sent it to the «MDUL»Press«MDNM»; and, I shall direct the «MDUL»Printer«MDNM» to commit as few «MDUL»Errors«MDNM» as possible.«MDUL»")}/, 'HN10 I should be very sorry to offend the «MDUL»Dean«MDNM», although I am a perfect Stranger to his «MDUL»Person«MDNM»: But, since the «MDUL»Poem«MDNM» will infallibly be soon printed, either «MDUL»here«MDNM», or in «MDUL»Dublin«MDNM», I take myself to have the best «MDUL»Title«MDNM» to sent it to the «MDUL»Press«MDNM»; and, I shall direct the «MDUL»Printer«MDNM» to commit as few «MDUL»Errors«MDNM» as possible.'
      line = line.gsub /«MDNM»   HN11/, 'HN11'
      line = line.gsub /#{Regexp.escape("HN1 «MDUL»By Honest «FN1«MDNM»·")}/, 'HN1 «MDUL»By Honest «FN1·'
      line = line.gsub /#{Regexp.escape("HN2 «MDNM»W«MDSD»RITTEN«MDNM» in the Y«MDSD»EAR«MDNM» 1729.")}/, 'HN2 W«MDSD»RITTEN«MDNM» in the Y«MDSD»EAR«MDNM» 1729.'
          
        line = line.gsub /#{Regexp.escape("HN1 «MDNM»To Y«MDSU»e«MDNM» Tune of the Cutpurse.")}/, 'HN1 To Y«MDSU»e«MDNM» Tune of the Cutpurse.'
        
        line = line.gsub /#{Regexp.escape("HN9 I «MDSD»SHOULD«MDNM» be very sorry to offend the D«MDSD»EAN«MDNM», although I am a perfect Stranger to His «MDUL»Person«MDNM»: But, since the «MDUL»Poem«MDNM» will infallibly be soon printed, either «MDUL»here«MDNM», or in «MDUL»Dublin«MDNM», I take myself to have the best «MDUL»Title«MDNM» to send it to the «MDUL»Press«MDNM»; and, I shall direct the «MDUL»Printer«MDNM» to commit a few «MDUL»Errors«MDNM» as possible.«MDUL»")}/, "HN9 I «MDSD»SHOULD«MDNM» be very sorry to offend the D«MDSD»EAN«MDNM», although I am a perfect Stranger to His «MDUL»Person«MDNM»: But, since the «MDUL»Poem«MDNM» will infallibly be soon printed, either «MDUL»here«MDNM», or in «MDUL»Dublin«MDNM», I take myself to have the best «MDUL»Title«MDNM» to send it to the «MDUL»Press«MDNM»; and, I shall direct the «MDUL»Printer«MDNM» to commit a few «MDUL»Errors«MDNM» as possible."
          
        line = line.gsub /#{Regexp.escape("«MDNM»Contrast«MDUL» of wearing Scarlet and Gold, with what they call «FN1·«MDNM»Wigs with long black Tails")}/, "«MDNM»Contrast«MDUL» of wearing Scarlet and Gold, with what they call «FN1·Wigs with long black Tails"
        line = line.gsub /#{Regexp.escape("HN1 «MDNM»Upon lending")}/, "HN1 Upon lending"
        line = line.gsub /#{Regexp.escape("HN1 «MDNM»In L«MDSD»ILLIPUTIAN«MDNM» VERSE.")}/, "HN1 In L«MDSD»ILLIPUTIAN«MDNM» VERSE."

        line = line.gsub /#{Regexp.escape("supplements; which answering my expectation, the perusal has produced what you find inclosed.")}$/, "supplements; which answering my expectation, the perusal has produced what you find inclosed.«MDNM»"

        line = line.gsub /#{Regexp.escape("«MDNM»HN4 «MDUL»As I have been somewhat inclined to this folly")}/, "HN4 «MDUL»As I have been somewhat inclined to this folly"
          
          # line = line.gsub /#{Regexp.escape("HN2 «MDRV»T«MDUL»HE Author of the following Poem, is said to be Dr. «MDNM»J. S. D. S. P. D«MDUL». who writ it, as well as several other Copies of Verses of the like Kind, by Way of Amusement, in the Family of an honourable Gentleman in the North of «MDNM»Ireland«MDUL», where he spent a Summer about two or three Years ago")}$/, 'HN2 «MDRV»T«MDUL»HE Author of the following Poem, is said to be Dr. «MDNM»J. S. D. S. P. D«MDUL». who writ it, as well as several other Copies of Verses of the like Kind, by Way of Amusement, in the Family of an honourable Gentleman in the North of «MDNM»Ireland«MDUL», where he spent a Summer about two or three Years ago«MDNM»'

        line = line.gsub /#{Regexp.escape("«MDNM»HN3")}\s+#{Regexp.escape("«MDUL»A certain very great Person, then in that Kingdom, having heard much of this Poem, obtained a Copy from the Gentleman, or, as some say, the Lady, in whose House it was written, from whence, I know not by what Accident, several other Copies were transcribed, full of Errors. As I have a great Respect for the supposed Author, I have procured a true Copy of the Poem, the Publication whereof can do him less Injury than printing any of those incorrect ones which run about in Manuscript, and would infallibly be soon in the Press, if not thus prevented.")}/, 'HN3    «MDUL»A certain very great Person, then in that Kingdom, having heard much of this Poem, obtained a Copy from the Gentleman, or, as some say, the Lady, in whose House it was written, from whence, I know not by what Accident, several other Copies were transcribed, full of Errors. As I have a great Respect for the supposed Author, I have procured a true Copy of the Poem, the Publication whereof can do him less Injury than printing any of those incorrect ones which run about in Manuscript, and would infallibly be soon in the Press, if not thus prevented.«MDNM»'
        line = line.gsub /#{Regexp.escape("«MDNM»HN4")}\s+#{Regexp.escape("«MDUL»Some Expressions being peculiar to «MDNM»Ireland«MDUL», I have prevailed on a Gentleman of that Kingdom to explain them, and I have put the several Explainations i,n their proper Places.«MDNM»")}/, 'HN4    «MDUL»Some Expressions being peculiar to «MDNM»Ireland«MDUL», I have prevailed on a Gentleman of that Kingdom to explain them, and I have put the several Explainations i,n their proper Places.«MDNM»'
        line = line.gsub /#{Regexp.escape("HN2 «MDNM»Written in the Y«MDSD»EAR«MDNM» 1712.")}/, 'HN2 Written in the Y«MDSD»EAR«MDNM» 1712.'
        line = line.gsub /#{Regexp.escape("HN«MDNM»1 «MDUL»To an agreeable young Lady, but extremely lean«MDNM».")}/, 'HN1 «MDUL»To an agreeable young Lady, but extremely lean«MDNM».'
        line = line.gsub /#{Regexp.escape("HN2 «MDNM»Written in the Year 1730.")}/, 'HN2 Written in the Year 1730.'
        line = line.gsub /#{Regexp.escape("HN1 «MDNM»Written «MDUL»Anno«MDNM» 1713.")}/, 'HN1 Written «MDUL»Anno«MDNM» 1713.'
        line = line.gsub /#{Regexp.escape("HN1 «MDNM»")}/, 'HN1'
        line = line.gsub /#{Regexp.escape("HN1«MDNM»")}/, 'HN1'
          
        line = line.gsub /#{Regexp.escape("_|A certain very great person«FN1«MDNM»·John Lord Carteret, then Lord Lieutenant of Ireland, afterwards Earl of Granville in right of his mother.«MDUL»»")}/, '_|A certain very great person«FN1·John Lord Carteret, then Lord Lieutenant of Ireland, afterwards Earl of Granville in right of his mother.»'
          
        line = line.gsub /#{Regexp.escape("«FN1·«MDNM»")}/, '«FN1·'
        
        line = line.gsub /#{Regexp.escape("HN3 TO «MDUL»Alexander Pope«MDNM», Esq; OF «MDUL»Twickenham«MDNM» in the County of «MDUL»MIDDLESEX«MDNM».«MDRV»")}/, 'HN3 TO «MDUL»Alexander Pope«MDNM», Esq; OF «MDUL»Twickenham«MDNM» in the County of «MDUL»MIDDLESEX«MDNM».'
          
        line = line.gsub /#{Regexp.escape("«MDNM»Advertisement._«MDRV»T«MDNM»HE Subject of the following POEM, is the «MDUL»South-Sea«MDNM»: It is ascribed to a great Name, but whether truly or no, I shall not presume to determine, nor add any thing more than that the Work is Universally approved of.")}/, 'Advertisement._«MDRV»T«MDNM»HE Subject of the following POEM, is the «MDUL»South-Sea«MDNM»: It is ascribed to a great Name, but whether truly or no, I shall not presume to determine, nor add any thing more than that the Work is Universally approved of.'
          
        line = line.gsub /#{Regexp.escape("«MDUL»Quid scribam vobis, vel quid omnino non scribam, | Dii me De\ae\que perdant, si satis scio.·· S«MDSD»UET«MDNM».")}/, ''
        line = line.gsub /#{Regexp.escape("«MDNM»Upon a «MDUL»Maxim«MDNM» in «MDUL»Rochefoucault«MDNM».")}/, 'Upon a «MDUL»Maxim«MDNM» in «MDUL»Rochefoucault«MDNM».'
        line = line.gsub /#{Regexp.escape("«X7")}\s*#{Regexp.escape("»")}/, ''
        line = line.gsub /#{Regexp.escape("«X8")}\s*#{Regexp.escape("»")}/, ''
        
        line = line.gsub /#{Regexp.escape("«MDNM»The Preface. | «MDRV»I«MDNM» «MDUL»HAVE been long of Opinion, that there is not a more general and greater Mistake, or of worse Consequences through the Commerce of Mankind, than the wrong Judgments they are apt to entertain of their own Talents: I knew a stuttering Alderman in «MDNM»London«MDUL»")}/, 'The Preface. | «MDRV»I«MDNM» «MDUL»HAVE been long of Opinion, that there is not a more general and greater Mistake, or of worse Consequences through the Commerce of Mankind, than the wrong Judgments they are apt to entertain of their own Talents: I knew a stuttering Alderman in «MDNM»London«MDUL»'
        line = line.gsub /#{Regexp.escape("HN2 «MDNM»Written in the Year 1731.")}/, 'HN2 Written in the Year 1731.'
          
        line = line.gsub /#{Regexp.escape("HN«MDNM»3")}/, 'HN3'
          
        line = line.gsub /#{Regexp.escape("HN1 At the D«MDSD»EANRY «MDNM»H«MDSD»OUSE, S«MDSD»T. «MDNM»P«MDSD»ATRICK'S«MDNM».")}/, "HN1 At the D«MDSD»EANRY «MDNM»H«MDSD»OUSE, ST. «MDNM»P«MDSD»ATRICK'S«MDNM»."
          
        # line = line.gsub /#{Regexp.escape("HN2 «MDBU»T«MDUL»HE Author of the following Poem is said to be Dr. «MDNM»J. S. D. S. P. D«MDUL». who writ it, as well as several other Copies of Verses of the like Kind, by Way of Amusement, in the Family of an honourable Gentleman in the North of «MDNM»Ireland«MDUL», where he spent a Summer about two or three Years ago.")}/, 'HN2 «MDBU»T«MDUL»HE Author of the following Poem is said to be Dr. «MDNM»J. S. D. S. P. D«MDUL». who writ it, as well as several other Copies of Verses of the like Kind, by Way of Amusement, in the Family of an honourable Gentleman in the North of «MDNM»Ireland«MDUL», where he spent a Summer about two or three Years ago.«MDNM»'

        # Work around for witnesses of the same apparatus (?)
        # @todo Resolve
        line = line.gsub /#{Regexp.escape("Years ago«MDNM».«MDNM»")}/, 'Years ago.«MDNM»'

        line = line.gsub /#{Regexp.escape("«MDNM»HN3 «MDUL»A certain very great «MDNM»")}/, 'HN3 «MDUL»A certain very great «MDNM»'
          
        # @todo Resolve this fully within SPP-124
        line = line.gsub /#{Regexp.escape("HN12 THE LIFE and CHARACTER OF Dean ")}.+/, 'HN12 THE LIFE and CHARACTER OF Dean S«DECORATOR»«/DECORATOR»t.'
        line = line.gsub /#{Regexp.escape("HN4 by an Express To y«MDSU»e«MDBO» «MDNM»| house would crep on \\«MDUL»?«MDNM»all 4s\\")}/, "HN4 by an Express To y«MDSU»e«MDNM» | house would crep on \\«MDUL»?«MDNM»all 4s\""
          
        # @todo Resolve this fully by implementing SPP-125
        line = line.gsub /#{Regexp.escape("«MDBU»Your most faithfull friend_&_Humble Serv«MDSU»t«MDBU» 08.__Will Livingston«MDNM»")}/, "«MDBU»Your most faithfull friend_&_Humble Serv«MDNM»«MDSU»t«MDNM»«MDBU» 08.__Will Livingston«MDNM»"

        # line = line.gsub /#{Regexp.escape("HN2 «MDRV»T«MDUL»HE Author of the following Poem is said to be Dr. «MDNM»J.S. D.S.P.D.«MDUL» who writ it, as well as several other Copies of Verse of the like Kind, by Way of Amusement, in the Family of an honourable Gentleman in the North of «MDNM»Ireland«MDUL», where he spent a Summer about two or three Years ago.")}/, "HN2 «MDRV»T«MDUL»HE Author of the following Poem is said to be Dr. «MDNM»J.S. D.S.P.D.«MDUL» who writ it, as well as several other Copies of Verse of the like Kind, by Way of Amusement, in the Family of an honourable Gentleman in the North of «MDNM»Ireland«MDUL», where he spent a Summer about two or three Years ago.«MDNM»"
        line = line.gsub /#{Regexp.escape("«MDNM»HN3 «MDUL»")}/, "HN3 «MDUL»"

        # line = line.gsub /#{Regexp.escape("of wearing Scarlet and Gold, with what they call «FN1·«MDNM»Wigs with long black Tails, worn for some Years Past.")}/, "of wearing Scarlet and Gold, with what they call«MDNM» «FN1·Wigs with long black Tails, worn for some Years Past."
        
        # ???
        # @todo Identify the source of this
        # @todo Refactor
        # line = line.gsub /#{Regexp.escape("«MDUL»November«MDNM» 1738.«MDUL»» ")}/, "«MDUL»November«MDNM» 1738.» «MDUL»"
        # line = line.gsub /#{Regexp.escape("wearing Scarlet and Gold, with what they call «FN1·")}/, "wearing Scarlet and Gold, with what they call«MDNM» «FN1·Wigs with long black Tails, worn for some Years Past."

        line = line.gsub /#{Regexp.escape("HN4  «MDRV»T«MDUL»HE author of the following poem is said to be Dr «MDNM»J. S. D. S. P. D«MDUL» who writ it, as well as several other copies of verses of the like kind, by way of amusement, in the family of an Honourable gentleman in the north of Ireland, where he spent a summer about two or three years ago. _|A certain very great person«FN1·John Lord Carteret, then Lord Lieutenant of Ireland, afterwards Earl of Granville in right of his mother.«MDUL»», then in that kingdom, having heard much of this poem, obtained a copy from the gentleman, or, as some say, the lady, in whose house it was written; from whence, I know not by what accident, several other copies were transcribed, full of errors. As I have a great respect for the supposed author, I have procured a true copy of the poem; the publication whereof can do him less injury than printing any of those incorrect ones which ran about in manuscript, and would infallibly be soon in the press, if not thus prevented._|Some expressions being peculiar to Ireland, I have prevailed on a gentleman of that kingdom to explain them, and I have put the several explanations in their proper places«MDNM».")}/, "HN4  «MDRV»T«MDUL»HE author of the following poem is said to be Dr «MDNM»J. S. D. S. P. D«MDUL» who writ it, as well as several other copies of verses of the like kind, by way of amusement, in the family of an Honourable gentleman in the north of Ireland, where he spent a summer about two or three years ago. _|A certain very great person«FN1·John Lord Carteret, then Lord Lieutenant of Ireland, afterwards Earl of Granville in right of his mother.», then in that kingdom, having heard much of this poem, obtained a copy from the gentleman, or, as some say, the lady, in whose house it was written; from whence, I know not by what accident, several other copies were transcribed, full of errors. As I have a great respect for the supposed author, I have procured a true copy of the poem; the publication whereof can do him less injury than printing any of those incorrect ones which ran about in manuscript, and would infallibly be soon in the press, if not thus prevented._|Some expressions being peculiar to Ireland, I have prevailed on a gentleman of that kingdom to explain them, and I have put the several explanations in their proper places«MDNM»."

        line = line.gsub(/#{Regexp.escape("«MDNM» «FN1·Wigs with long black Tails, worn for some Years Past.Wigs with long black Tails, worn for some Years past. «MDUL»November«MDNM» 1738.» Toupees")}/, "«MDNM» «FN1·Wigs with long black Tails, worn for some Years Past.Wigs with long black Tails, worn for some Years past. «MDUL»November«MDNM» 1738.» «MDUL»Toupees")      
    end

    # Refactor
    def parse(line)

      line = line.gsub /──»/, '──.»'

      # Resolves issues related to certain footnote terminating modecodes
      # See SPP-93
      line = line.gsub /([a-z\.]\d+?)»/, '\\1.»'
      line = line.gsub /([a-z\\])»/, '\\1.»'

      # For cleaning extraneous MDNM mode codes
      # @todo Refactor into a CSV file for parsing (original line, cleaned line)
      #
      clean line if @cleanModeCodes
      
      # Parse for the HN index
      m = /HN(\d\d?) ?(.*)/.match(line)
      if not m

        # If this is not present, check with the TEI document in order to determine whether or not a HN was previously opened
        if @teiParser.headnote_open

          headIndex = @teiParser.headnote_opened_index
          headContent = line
        else

          raise NotImplementedError.new "Failed to parse the following line as a headnote: #{line}"
        end
      else

        # headIndex = m[1]

        # Update the index of the currently opened HN
        @teiParser.headnote_opened_index = m[1]
        headIndex = @teiParser.headnote_opened_index

        headContent = m[2]

        # @todo Refactor
        # @heads.pushHead if @teiParser.headnote_opened_index.to_i > 1
        if @teiParser.headnote_opened_index.to_i > 1

          # puts "Closing the line...\n"

          @heads.pushHead
        end
      end

      # This needs to be refactored for tokens which encoded content beyond that of 1 line
      if headContent != ''

        # Push the tokenized NB content of each HN line to the set of HN's

        # puts "head Content: #{headContent}"

        initialTokens = headContent.split /(?=«)|(?=\.»)|(?<=«FN1·)|(?<=»)|\s(?=om\.)|(?<=om\.)|(?=\|)|(?<=\|)|(?=_)|(?<=_)|\n/

        # puts "initialTokens: #{initialTokens}"

        initialTokens.each do |initialToken|

          # poem.push initialToken
          @heads.push initialToken
        end
      end
    end
  end
end
