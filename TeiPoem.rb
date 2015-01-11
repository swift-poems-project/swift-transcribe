# -*- coding: utf-8 -*-

module SwiftPoemsProject

  NB_BLOCK_LITERAL_PATTERNS = [
                               /(«MDSU»\*\*?«MDSD»\*)+«MDSU»\*«MDNM»\*?/,
                               /#{Regexp.escape("«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»**«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*«MDSD»*«MDSU»*")}/,
                              ]

  class TeiPoem

    def self.normalize(poem)

       # poem = poem.gsub(/(«MDUL»[[:alnum:]]+?)_([[:alnum:]]+«MDNM»)/, "$1<lb />$2")
       # poem = poem.gsub(/(?<!08|_)_/, '<lb />')

       # initialTokens = poem.split /(?=«)|(?=»)|(?<=«FN1·)|(?<=»)|(?=om\.)|(?<=om)|\n/
       # initialTokens = poem.split /(?=«)|(?<=«FN1·)|(?<=»)|(?=om\.)|(?<=om)|\n/

       poem = poem.gsub /«X4The\sEpitaph»/, ''
       poem = poem.gsub /«X2»/, ''

       # Substitutions for names: 18th century convention
       poem = poem.gsub /(\─)+»/, '\\1.»'

      poem = poem.gsub /«LD─\.?»/, "«LD »"
      poem = poem.gsub /«FC»«MDNM»/, "«FC»"
      poem = poem.gsub /«FL»_/, "_«FL»"

      poem = poem.gsub /\.»/, '..»'
      poem = poem.gsub /\)»/, ').»'
      poem = poem.gsub /\*»/, '*.»'
      poem = poem.gsub /\?»/, '?.»'
      poem = poem.gsub /`»/, '`.»'
      poem = poem.gsub /'»/, "'.»"
      poem = poem.gsub /!»/, "!.»"
      poem = poem.gsub /;»/, ";.»"
      poem = poem.gsub /,»/, ",.»"
      poem = poem.gsub /»\s»/, '» .»'
      poem = poem.gsub /\-»/, '-.»'
      
      poem = poem.gsub /H»/, "H.»"
      
      poem = poem.gsub /«MDbu»/, "«MDBU»"
      
      poem = poem.gsub /«ld »/, "«LD »"
      poem = poem.gsub /«LS»/, "«LD »"
      
      poem = poem.gsub /«MDUL»«FN1·/, "«FN1·«MDUL»"
      poem = poem.gsub /«MDUL»»«MDNM»/, "»"
      poem = poem.gsub /«MDNM»country Parsons«MDNM»/, "country Parsons«MDNM»"
      
      poem = poem.gsub /«FN1«MDUL»·/, '«FN1·«MDUL»'
      poem = poem.gsub /«FN1«MDNM»·/, '«FN1·'
      poem = poem.gsub /«FN1 /, '«FN1·'
      poem = poem.gsub /«FN1([0-9A-Z])/, '«FN1·\\1'
      poem = poem.gsub /«FN1\|·/, "«FN1·"
      poem = poem.gsub /«FN1\\/, "«FN1·\\"
      
      poem = poem.gsub(/#{Regexp.escape("«FN1──────")}/, "«FN1·──────")
      
      poem = poem.gsub /\\»/, "\\.»"
      
      poem = poem.gsub /Hor\.\|» midnight Dream/, "Hor.» midnight Dream"
      poem = poem.gsub /\}«MDNM»3/, "}3"
      
      poem = poem.gsub /([\]\?\:a-z0-9])»/, '\\1.»'
      poem = poem.gsub /«MDRV»»/, '.»'
      poem = poem.gsub /«MDUL»»/, '.»'
      
      poem = poem.gsub /LD\s»/, 'LD»'
      poem = poem.gsub /.\s+»/, '.»'
      
      poem = poem.gsub /·»/, '.»'
      
      poem = poem.gsub /([[:lower:]])»/, '\\1.»'
      
      poem = poem.gsub /553E06E2   524  ``But── not one sermon«MDNM», you may «MDUL»swear«MDNM».────/, "553E06E2   524  ``But── not one sermon, you may «MDUL»swear«MDNM».────"
      poem = poem.gsub /284-0204   34  Form'd like the Triple-Tree near «FN1Where the «MDUL»Dublin«MDBO» «MDNM»Gallows stands·» «MDUL»Stephen's Green«MDNM»,/, "284-0204   34  Form'd like the Triple-Tree near «FN1Where the «MDUL»Dublin«MDNM» Gallows stands·» «MDUL»Stephen's Green«MDNM»,"
      poem = poem.gsub /098-0204   16  «MDNM»Howe'er our earthly Motion varies;/, "098-0204   16  Howe'er our earthly Motion varies;"
      poem = poem.gsub /098-0204   18  «MDNM»As if there had been no such Matter./, "098-0204   18  As if there had been no such Matter."
      poem = poem.gsub /098-0204   21  «MDNM»/, "098-0204   21  "
      poem = poem.gsub /098-0204   29  «MDNM»Which clearly shews the near Alliance/, "098-0204   29  Which clearly shews the near Alliance"
      poem = poem.gsub /098-0204   30  'Twixt «MDUL»Cobling«MDNM»,«MDNM» and the «MDUL»Planets Science«MDNM»./, "098-0204   30  'Twixt «MDUL»Cobling«MDNM», and the «MDUL»Planets Science«MDNM»."
      poem = poem.gsub /098-0204   32  «MDNM»As 'tis miscall'd, we know not who 'tis:/, "098-0204   32  As 'tis miscall'd, we know not who 'tis:"
      poem = poem.gsub /098-0204   35  _\|The «MDUL»horned Moon«MDNM»,«MDNM» which heretofore/, "098-0204   35  _\|The «MDUL»horned Moon«MDNM», which heretofore"
      poem = poem.gsub /098-0204   42  «MDNM»\(A great Refinement in «MDUL»Barometry«MDNM»\)/, "098-0204   42  (A great Refinement in «MDUL»Barometry«MDNM»)"
      poem = poem.gsub /098-0204   45  «MDNM»Which an Astrologer might use,/, "098-0204   45  Which an Astrologer might use,"
      poem = poem.gsub /098-0204   47  _\|Thus «MDUL»Partrige«MDNM»,«MDNM» by his Wit and Parts,/, "098-0204   47  _|Thus «MDUL»Partrige«MDNM», by his Wit and Parts,"
      poem = poem.gsub /098-0204   51  «MDNM»/, "098-0204   51  "
      poem = poem.gsub /098-0204   85  «MDNM»/, "098-0204   85  "
      poem = poem.gsub /098-0204   87  «MDNM»/, "098-0204   87  "
      poem = poem.gsub /098-0204   91  «MDNM»/, "098-0204   91  "
      poem = poem.gsub /«FN1·«MDNM»C«MDSD»HARLES «MDNM»F«MDSD»ITZROY«MDNM»/, "«FN1·C«MDSD»HARLES «MDNM»F«MDSD»ITZROY«MDNM»"
      poem = poem.gsub /«MDUL»«FN1·Ridiculum/, "«FN1·«MDUL»Ridiculum"
     poem = poem.gsub /«MDNM», &c..» Horace«MDNM»,/, "«MDNM», &c..» «MDUL»Horace«MDNM»,"
     poem = poem.gsub /«MDUL»Bread«MDNM»;«MDNM»/, "«MDUL»Bread«MDNM»;"

     # This was resolved manually on 08/11/14
     # poem = poem.gsub /\|\|Of «MDUL»arma virumque,/, "||Of «MDUL»arma virumque,«MDNM»"
     poem = poem.gsub /«FN1·«MDNM»The duchy/, "«FN1·The duchy"
     poem = poem.gsub /» Hanoni/, "» «MDUL»Hanoni"

#     poem = poem.gsub /«MDRV»B«MDNM»Y an «MDBU»old red·pate murdring hag «/, "«MDRV»B«MDNM»Y an «MDBU»old red·pate murdring hag «MDNM»«"
#     poem = poem.gsub /Coningsmark«MDNM»» «MDNM»pursu'd,/, "Coningsmark«MDNM»» pursu'd,"

     poem = poem.gsub /531-02U1   8  For thee, than make a «MDNM»«FN1·/, "531-02U1   8  For thee, than make a «FN1·"
     poem = poem.gsub /763B36L\-   2  Shall still«MDNM» be kept with Joy by me/, "763B36L-   2  Shall still be kept with Joy by me"
     poem = poem.gsub /740C422R   53  First, \\«MDUL»add«MDNM»·«FN1·She«MDNM»/, "740C422R   53  First, \«MDUL»add«MDNM»·«FN1·She"
     poem = poem.gsub /069-0251   66  So, my «MDUL»Lord«MDNM» call'd me; «FN1·«MDUL»A Cant Word of my Lord and Lady to Mrs«MDNM»\. Harris\.«MDNM»/, "069-0251   66  So, my «MDUL»Lord«MDNM» call'd me; «FN1·«MDUL»A Cant Word of my Lord and Lady to Mrs«MDNM». Harris."
     poem = poem.gsub /136-21D-   61  «MDNM»Sweepings/, "136-21D-   61  Sweepings"
     poem = poem.gsub /734\-03P4   15  _\|N«MDSD»OW«MDNM», «MDNM»this is «MDUL»Stella«MDNM»'s Case in Fact,/, "734-03P4   15  _|N«MDSD»OW«MDNM», "
     poem = poem.gsub /082\-03P4   47  _\|«MDNM»F«MDSD»ARTHER«MDNM» we are by «MDUL»Pliny«MDNM» told,/, "082-03P4   47  _|F«MDSD»ARTHER«MDNM» we are by «MDUL»Pliny«MDNM» told,"
     poem = poem.gsub /947B907A   4  And that you adore «MDUL»him«MDNM», because he adores«MDNM» «MDUL»you«MDNM»\./, "947B907A   4  And that you adore «MDUL»him«MDNM», because he adores «MDUL»you«MDNM»."
     poem = poem.gsub /08\. Thomas asserted that the Book deserved the Censure of the House; & some days afterwards acquainted them in an explanation of his former Oration that he would have punish'd the Author, «MDUL»if he could «MDNM»\\«MDNM»add/, "08. Thomas asserted that the Book deserved the Censure of the House; & some days afterwards acquainted them in an explanation of his former Oration that he would have punish'd the Author, «MDUL»if he could «MDNM»\add"

     # Duplicated
     # poem = poem.gsub /866\-271R   180  As, who should say; N«MDSD»OW«MDNM», «MDUL»am «MDNM»\\del·«MDUL»a«MDNM»·add·«MDUL»I«MDNM»\\«MDUL» «FN1·«MDNM»Nick\-names for my Lady\.\.?» Skinny and Lean«MDNM»\?/, "866-271R   180  As, who should say; N«MDSD»OW«MDNM», «MDUL»am «MDNM»\del·«MDUL»a«MDNM»·add·«MDUL»I«MDNM»\ «FN1·Nick-names for my Lady.» «MDUL»Skinny and Lean«MDNM»?"

     poem = poem.gsub /357-176Y   17  Rejocing y«MDSU»t«MDNM» 08«MDNM»\. in Better Times/, "357-176Y   17  Rejocing y«MDSU»t«MDNM» 08. in Better Times"
     poem = poem.gsub /082\-WILH   46  \|Sure that must be a«MDNM» Salamander«MDNM»!/, "082-WILH   46  |Sure that must be a«MDNM» Salamander!"
     poem = poem.gsub /829\-1151   193  _\|B«MDSD»LESS«MDNM» us, «MDUL»Morgan«MDNM»!«MDNM» Art thou there, Man\?/, "829-1151   193  _|B«MDSD»LESS«MDNM» us, «MDUL»Morgan«MDNM»! Art thou there, Man?"
     
     poem = poem.gsub /480-S877   186  From «MDUL»Hell«MDNM» a «MDUL»V«MDNM»-------«MDNM» DEV'L ascends,/, "480-S877   186  From «MDUL»Hell«MDNM» a «MDUL»V«MDNM»------- DEV'L ascends,"
     poem = poem.gsub /102\-S849   63  because, I believe, it is pretty scarce\.«MDNM»/, "102-S849   63  because, I believe, it is pretty scarce."
     poem = poem.gsub /239\-S900   7  Breaking «MDNM»the «MDUL»Bankers«MDNM» and the «MDUL»Banks«MDNM»,/, "239-S900   7  Breaking the «MDUL»Bankers«MDNM» and the «MDUL»Banks«MDNM»,"
     poem = poem.gsub /239\-S900   14  Quakers«MDNM», and «MDUL»Aldermen«MDNM», in State,/, "239-S900   14  Quakers, and «MDUL»Aldermen«MDNM», in State,"
     poem = poem.gsub /239\-S900   22  Make Pinions for themselves to fly«MDNM»,/, "239-S900   22  Make Pinions for themselves to fly,"
     poem = poem.gsub /239\-S900   26  Bills«MDNM» turn the Lenders into Debters,/, "239-S900   26  Bills turn the Lenders into Debters,"
     poem = poem.gsub /239\-S900   64  «MDUL»Weigh'd in the Ballance, and found Light«MDNM»\.«MDNM»/, "239-S900   64  «MDUL»Weigh'd in the Ballance, and found Light«MDNM»."

     poem = poem.gsub /383\-S818   1  «MDRV»O«MDNM»NCE«MDNM» on a Time, a righteous Sage,/, "383-S818   1  «MDRV»O«MDNM»NCE on a Time, a righteous Sage,"

     poem = poem.gsub /098\-S833   92  She'll strain a Point, and sit «FN1·«MDUL»Tibi brachia contrahet ingens Scorpius«MDNM», &c.«MDNM»» astride/, "098-S833   92  She'll strain a Point, and sit «FN1·«MDUL»Tibi brachia contrahet ingens Scorpius, &c.«MDNM»» astride"
     
     poem = poem.gsub /098\-S833   101  \|«FN1·«MDUL»Sed nec in Arctoo sedem tibi legeris orbe«MDNM», &c.«MDNM»»But do not shed thy Influence down/, "098-S833   101  |«FN1·«MDUL»Sed nec in Arctoo sedem tibi legeris orbe, &c.«MDNM».»But do not shed thy Influence down"

     poem = poem.gsub(/#{Regexp.escape("Importunity of«MDNM» *·*·|*·*«MDNM»»Provided «MDUL»Bolingbroke«MDNM» were dead.")}/, "Importunity of«MDNM» *·*·|*·*.»Provided «MDUL»Bolingbroke«MDNM» were dead.")
     poem = poem.gsub(/#{Regexp.escape("«MDNM», &c._──────· ────·· ───────·· ────·· ──────· ──────·  ──·· ──────·· ──· ────· ────·· ──«MDNM»")}/, "«MDNM», &c._──────· ────·· ───────·· ────·· ──────· ──────·  ──·· ──────·· ──· ────· ────·· ──")
     poem = poem.gsub(/#{Regexp.escape("Act«MDNM», *····· *······ *······ *······ *······ *······ *······ *······ *······ *······ *«MDNM»»")}/, "Act«MDNM», *····· *······ *······ *······ *······ *······ *······ *······ *······ *······ *.»")

     poem = poem.gsub(/#{Regexp.escape("553KS920   247  Where's now the Favourite of «MDUL»Apollo«MDNM»?«MDNM»")}/, "553KS920   247  Where's now the Favourite of «MDUL»Apollo«MDNM»?")

     poem = poem.gsub(/#{Regexp.escape("098-S832   1  «MDRV»W«MDNM»ELL«MDNM»")}/, "098-S832   1  «MDRV»W«MDNM»ELL")
     poem = poem.gsub(/#{Regexp.escape("098-S832   104  «MDNM»")}/, "098-S832   104  ")
     poem = poem.gsub(/#{Regexp.escape("553-S931   197  «FN1·Curl, «MDUL»hath been the most infamous Bookseller of any Age or Country: His Character in Part may be found in Mr«MDNM». «MDNM»P«MDSD»OPE«MDNM»'s «MDUL»Dunciad. He published three Volumes all charged on the Dean, who never writ three Pages of them: He hath used many of the Dean's Friends in almost as vile a Manner«MDNM»..»Now «MDUL»Curl«MDNM» his Shop from Rubbish drains;")}/, "553-S931   197  «FN1·Curl, «MDUL»hath been the most infamous Bookseller of any Age or Country: His Character in Part may be found in Mr«MDNM». P«MDSD»OPE«MDNM»'s «MDUL»Dunciad. He published three Volumes all charged on the Dean, who never writ three Pages of them: He hath used many of the Dean's Friends in almost as vile a Manner«MDNM»..»Now «MDUL»Curl«MDNM» his Shop from Rubbish drains;")

     poem = poem.gsub(/#{Regexp.escape("537-07H1   1  «MDRV»S«MDNM»IR Robert«MDNM»")}/, "537-07H1   1  «MDRV»S«MDNM»IR Robert")
     poem = poem.gsub(/#{Regexp.escape("749-07H1   1  «MDRV»D«MDNM»ON Carlos«MDNM»")}/, "749-07H1   1  «MDRV»D«MDNM»ON Carlos")
     poem = poem.gsub(/#{Regexp.escape("X00-07H1   1  T«MDNM»")}/, "X00-07H1   1  T")
     poem = poem.gsub(/#{Regexp.escape("584-07H1   1  «MDRV»O«MDNM»F Chloe«MDNM»")}/, "584-07H1   1  «MDRV»O«MDNM»F Chloe")
     poem = poem.gsub(/#{Regexp.escape("062-07H1   1  «MDRV»W«MDNM»HEN«MDNM»")}/, "062-07H1   1  «MDRV»W«MDNM»HEN")
     poem = poem.gsub(/#{Regexp.escape("949A05P4   7  _«FC»In «MDUL»ENGLISH«MDNM».«FL»__«MDRV»W«MDNM»HO«MDNM»")}/, "949A05P4   7  _«FC»In «MDUL»ENGLISH«MDNM».«FL»__«MDRV»W«MDNM»HO")

     poem = poem.gsub(/#{Regexp.escape("866-0204   180  As, who shou'd say, ")}.+\?/, "866-0204   180  As, who shou'd say, «MDUL»Now, am I«MDNM»«FN1·Nick-names for my Lady..»«MDUL»Skinny and Lean?«MDNM»")

     poem = poem.gsub(/X44\-612B   6  A back\-sword, poker, with\\«MDUL»ins«MDNM»·out«MDNM»/, "X44-612B   6  A back-sword, poker, with\«MDUL»ins«MDNM»·out")
     poem = poem.gsub(/#{Regexp.escape("P0030603   2  ``As often as they change their Cloaths«MDNM»")}/, "P0030603   2  ``As often as they change their Cloaths")

     # Duplicate
#     poem = poem.gsub(/#{Regexp.escape("186B1451   5  ||Of «MDUL»arma virumque,")}/, "186B1451   5  ||Of «MDUL»arma virumque,«MDNM»")
     poem = poem.gsub(/186B1451   6  «MDNM»«FN1·The duchy of «MDUL»Hainault«MDNM»\.\.»«MDUL»Hanoni\\ae\\ qui primus ab oris«MDNM»\./, "186B1451   6  «FN1·The duchy of «MDUL»Hainault«MDNM»..»«MDUL»Hanoni\ae\ qui primus ab oris«MDNM».")

     poem = poem.gsub(/#{Regexp.escape("553-54B-   70  But this with envy makes me burst«MDNM».")}/, "553-54B-   70  But this with envy makes me burst.")

     # poem = poem.gsub(/#{Regexp.escape("bless the Church, and three of our Mitres;")}/, "bless the Church, and three of our Mitres;«MDNM»")
     poem = poem.gsub(/#{Regexp.escape("803-05P1   63  _|S«MDSD»O «MDNM»G«MDSD»OD bless the Church, and three of our Mitres;")}/, "803-05P1   63  _|S«MDSD»O «MDNM»G«MDSD»OD bless the Church, and three of our Mitres;«MDNM»")

     poem = poem.gsub(/#{Regexp.escape("«FN1·The Ode I writ to the King in«MDNM» Ireland")}/, "«FN1·The Ode I writ to the King in Ireland")

     # poem = poem.gsub(/#{Regexp.escape("\Greek shoulder note\«MDUL»» God Himself to help him out«MDNM»\.")}/, "\Greek shoulder note\» «MDUL»God Himself to help him out«MDNM».")
     # poem = poem.gsub(/«FN1·«MDNM»\\Greek shoulder note\\«MDUL»» God Himself to help him out«MDNM»\./, '«FN1·\Greek shoulder note\» «MDUL»God Himself to help him out«MDNM».')
     poem = poem.gsub(/«FN1·«MDNM»\\Greek shoulder note\\\.» God Himself to help him out«MDNM»\./, '«FN1·\Greek shoulder note\.» «MDUL»God Himself to help him out«MDNM».')

     poem = poem.gsub(/#{Regexp.escape("866-S908   180  ``As, who shou'd say, «MDUL»Now am «FN1·«MDNM»")}/, "866-S908   180  ``As, who shou'd say, «MDUL»Now am«MDNM» «FN1·")

     poem = poem.gsub(/#{Regexp.escape("147-S941   26  Bury those «MDNM»Carrots«MDBO» under a«MDNM» Hill.«MDBO»")}/, "147-S941   26  Bury those «MDNM»Carrots«MDBO» under a«MDNM» Hill.")

     # Work-around
     # @todo Refactor
     poem = poem.gsub(/#{Regexp.escape("971-WILH   14  «FN1·«MDUL»The Dean's Answer..»«MDNM»")}/, "971-WILH   14  «MDUL»«FN1·The Dean's Answer..»«MDNM»")

     poem = poem.gsub(/#{Regexp.escape("006-WILH   51  |«MDUL»In vain, «MDNM»said He«MDUL», does «FN1·Ireland«MDNM»» Utmost Thule«MDUL» boast")}/, "006-WILH   51  |«MDUL»In vain, «MDNM»said He«MDUL», does«MDNM» «FN1·Ireland» Utmost Thule«MDUL» boast")

     poem = poem.gsub(/#{Regexp.escape("006-HW37   1  «FC»«MDNM»I.«FL»_«MDNM»Sure«MDNM» there's some Wondrous Joy in «MDUL»Doing Good«MDNM»;")}/, "006-HW37   1  «FC»«MDNM»I.«FL»_«MDNM»Sure there's some Wondrous Joy in «MDUL»Doing Good«MDNM»;")

     # puts poem

       NB_BLOCK_LITERAL_PATTERNS.each do |pattern|

         # poem = poem.sub Regexp.new(Regexp.escape pattern), '«UNCLEAR»'
         poem = poem.sub pattern, '«UNCLEAR»'
       end

       return poem
     end

     def initialize(poem, work_type, element)

       @poem = poem
       @work_type = work_type
       @element = element

       @tokens = @poem.split /(?=«)|(?=[\.─\\a-z]»)|(?<=«FN1·)|(?<=»)|(?=om\.)|(?<=om\.)|\n/

       @stanzas = [ TeiStanza.new(@work_type, @element, 1) ]
     end

     def parse

       # Classify our tokens
       @tokens.each do |initialToken|

         # puts "Parsing the following into a stanza: #{initialToken}"

         raise NotImplementedError, initialToken if initialToken if /──────»/.match initialToken

         # Extend the handling for poems by addressing cases in which "_" characters encode new paragraphs within footnotes
         
         
         # Create a new stanza
         if m = /(.*)_$/.match(initialToken)

           # puts 'trace4' + @stanzas.last.elem.to_xml
           # debugOutput = @stanzas.last.opened_tags.map {|tag| tag.element.to_xml }
           # puts 'trace5' + debugOutput.to_s

           @stanzas.last.push m[1] unless m[1].empty?
           
           # Append the new stanza to the poem body
           @stanzas << TeiStanza.new(@work_type, @element, @stanzas.size + 1, { :opened_tags => Array.new(@stanzas.last.opened_tags) })
         else
           
           stanza_tokens = initialToken.split('_')

           # puts "stanza tokens: #{stanza_tokens}"
           
           while stanza_tokens.length > 1
             
             puts "Appending the token for the existing stanza: #{stanza_tokens.first}"
             
             @stanzas.last.push stanza_tokens.shift
             
             debugOutput = @stanzas.last.opened_tags.map {|tag| tag.to_xml }
             puts "Opened stanza tags: #{debugOutput}\n\n"
             
             # Append the new stanza to the poem body
             # @stanzas << TeiStanza.new(@work_type, @element, @stanzas.size + 1, { :opened_tags => Array.new(@stanzas.last.opened_tags) })
             @stanzas << TeiStanza.new(@work_type, @element, @stanzas.size + 1, { :opened_tags => @stanzas.last.opened_tags })

           end
           
           # Solution implemented for SPP-86
           #
           # @todo Refactor
           # puts initialToken
           if initialToken.match /^[^«].+?»$/
             
             raise NotImplementedError, "Could not parse the following terminal «FN1· sequence: #{initialToken}"
           end
           
           @stanzas.last.push stanza_tokens.shift           
         end
       end
     end
   end
end
