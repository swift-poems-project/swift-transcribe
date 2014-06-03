#!/usr/bin/env ruby"
# -*- coding: utf-8 -*-

require "/home/griffinj/ruby.d/ruby-tools/spp/SPPParser"
require "test/unit"
require 'nokogiri'
 
class AcceptanceTestSPPParser < Test::Unit::TestCase

  FILE_PATH = '366-001A'
  #FILE_PATH = '613-0653'

  def setup

    @parser = SPPParser.new(FILE_PATH)
  end

  def testParse366_001A

    @parser.heading = <<EOF
Transcription Form  -  25 July 2007
Swift Poems Project

Line below contains formatting deltas


«FM1MD=NM,FT=1,BF=1,SC=1,FL»«FS1«IP0,0»«LS1»
»«OF0»«RM80»«IP0,5»
$$                              Help: SPPDOC
$$                              «MDBO»Filename:«MDNM» 366-001A
$$                              «MDBO»Transcriber & date:«MDNM» JW 22AP09
$$«MDBO»First line:«MDNM» The wise pretend to make it clear
$$«MDBO»Source:«MDNM» MS miscellany, pp. 55-57
$$«MDBO»Library and shelfmark:«MDNM» DLC MS MMC Commonplace book by an unidentified individual, 18th century
$$«MDBO»Proofed by & dates:«MDNM» EBurnor 1JL11 from JW photos; ed. JW 21JA10, 8FE12
EOF

    @parser.parseHeader

    @parser.titleAndHeadnote = <<EOF
366-001A   Dr Delany wrote to Dr Swift, in order | to be admitted to speak to him when he | was Deaf. to which the Dean sent the | following Answer.
366-001A   HN1 Written in the Year 1724.
366-001A   HN2 
366-001A   HN3 
366-001A   
EOF

    @parser.parseTitleAndHeadnote
    
    @parser.poem = <<EOF
366-001A   1  |The wise pretend to make it clear,
366-001A   2  'Tis no great loss to lose an ear.
366-001A   3  Why are we then so fond of two,
366-001A   4  When by experience one would do.
366-001A   5  _|'Tis true, say they, cut off the head,
366-001A   6  And there's and end, the man is dead;
366-001A   7  Because among all human race,
366-001A   8  None e'er was known to have a brace;
366-001A   9  But confidently they maintain,
366-001A   10  That where we find the Members twain,
366-001A   11  The loss of one is no such trouble,
366-001A   12  Since t'other will in Strength be double:
366-001A   13  The limb Surviving you may swear,
366-001A   14  Becomes his brothers lawful heir.
366-001A   15  Thus for a trial let me beg of
366-001A   16  Your Rev'rence but to cut one Leg off
366-001A   17  And you shall find by this device
366-001A   18  The other will be stronger twice.
366-001A   19  For ev'ry day you shall be gaining
366-001A   20  New Vigor to the leg remaining:
366-001A   21  So when an Eye hath lost its Brother,
366-001A   22  You see the better with the other:
366-001A   23  Cut off your hand and you may do
366-001A   24  With t'other hand the Work of two:
366-001A   25  Because the Soul her pow'r Contracts,
366-001A   26  And on the Brother Limb «MDUL»reacts«MDNM».
366-001A   27  |But yet the point is not so clear in
366-001A   28  Another Case, the sense of hearing;
366-001A   29  For tho' the place of either Ear
366-001A   30  Be distant as one head can bear;
366-001A   31  Yet Galen most acutely shews you
366-001A   32  (Consult his book «MDUL»de partiam usu,)«MDNM»
366-001A   33  That from each ear as he observes,
366-001A   34  There crept two auditory nerves,
366-001A   35  Not to be seen without a Glass,
366-001A   36  Which near the Os «MDUL»petrosum«MDNM» pass,
366-001A   37  Thence to the Neck, and moving thorough there
366-001A   38  One goes to this, and one to t'other ear.
366-001A   39  Which made my grand-dame always stuff her Ears,
366-001A   40  Both right and left as fellow sufferrers.
366-001A   41  You see my Learning; but to shorten it,
366-001A   42  When my left ear was deaf a fortnigt,
366-001A   43  To t'other ear I felt it coming on
366-001A   44  And thus I solve this hard «MDUL»Ph\\ae\\nomenon«MDNM».
366-001A   45  Tis true a glass will bring supplies
366-001A   46  To weak, or old, or clouded Eyes:
366-001A   47  Your Arms, tho' both your eyes were lost,
366-001A   48  Would guard your nose against a post:
366-001A   49  Without your legs two Legs of Wood
366-001A   50  Are stronger and almost as good:
366-001A   51  And as for Hands there have been those,
366-001A   52  Who wanting both, have us'd their Toes«FN1·There was about this Time a man shew'd who wrote with his foot.»;
366-001A   53  But no Contrivance yet appears,
366-001A   54  To furnish artificial Ears.
EOF

    encodedPoem = '<text>
    <div type="book">
      <div type="poem" xml:id="366-001A">
      <lg type="stanza"><l rend="indent" n="1">The wise pretend to make it clear,</l><l n="2">\'Tis no great loss to lose an ear.</l><l n="3">Why are we then so fond of two,</l><l n="4">When by experience one would do.</l></lg><lg type="stanza"><l rend="indent" n="5">\'Tis true, say they, cut off the head,</l><l n="6">And there\'s and end, the man is dead;</l><l n="7">Because among all human race,</l><l n="8">None e\'er was known to have a brace;</l><l n="9">But confidently they maintain,</l><l n="10">That where we find the Members twain,</l><l n="11">The loss of one is no such trouble,</l><l n="12">Since t\'other will in Strength be double:</l><l n="13">The limb Surviving you may swear,</l><l n="14">Becomes his brothers lawful heir.</l><l n="15">Thus for a trial let me beg of</l><l n="16">Your Rev\'rence but to cut one Leg off</l><l n="17">And you shall find by this device</l><l n="18">The other will be stronger twice.</l><l n="19">For ev\'ry day you shall be gaining</l><l n="20">New Vigor to the leg remaining:</l><l n="21">So when an Eye hath lost its Brother,</l><l n="22">You see the better with the other:</l><l n="23">Cut off your hand and you may do</l><l n="24">With t\'other hand the Work of two:</l><l n="25">Because the Soul her pow\'r Contracts,</l><l n="26">And on the Brother Limb <hi rend="underline">reacts</hi>.</l><l rend="indent" n="27">But yet the point is not so clear in</l><l n="28">Another Case, the sense of hearing;</l><l n="29">For tho\' the place of either Ear</l><l n="30">Be distant as one head can bear;</l><l n="31">Yet Galen most acutely shews you</l><l n="32">(Consult his book <hi rend="underline">de partiam usu,)</hi></l><l n="33">That from each ear as he observes,</l><l n="34">There crept two auditory nerves,</l><l n="35">Not to be seen without a Glass,</l><l n="36">Which near the Os <hi rend="underline">petrosum</hi> pass,</l><l n="37">Thence to the Neck, and moving thorough there</l><l n="38">One goes to this, and one to t\'other ear.</l><l n="39">Which made my grand-dame always stuff her Ears,</l><l n="40">Both right and left as fellow sufferrers.</l><l n="41">You see my Learning; but to shorten it,</l><l n="42">When my left ear was deaf a fortnigt,</l><l n="43">To t\'other ear I felt it coming on</l><l n="44">And thus I solve this hard <hi rend="underline">Ph&#xE6;nomenon</hi>.</l><l n="45">Tis true a glass will bring supplies</l><l n="46">To weak, or old, or clouded Eyes:</l><l n="47">Your Arms, tho\' both your eyes were lost,</l><l n="48">Would guard your nose against a post:</l><l n="49">Without your legs two Legs of Wood</l><l n="50">Are stronger and almost as good:</l><l n="51">And as for Hands there have been those,</l><l n="52">Who wanting both, have us\'d their Toes<note place="foot">There was about this Time a man shew\'d who wrote with his foot.</note></l><l n="53">But no Contrivance yet appears,</l><l n="54">To furnish artificial Ears.</l></lg></div>
    </div>
  </text>'

    result = @parser.parsePoem
    assert_equal(result.to_xhtml, encodedPoem)

    @parser.footNotes = <<EOF
366-001A   $$«MDBO»Table of contents title:«MDNM» alpha
^Z
EOF



    @parser.footNotes = <<EOF
366-001A   $$«MDBO»Attribution:«MDNM» Swift
366-001A   $$«MDBO»Table of contents title:«MDNM» --
366-001A   $$«MDBO»Other title:«MDNM» Not listed in index
366-001A   $$«MDBO»Remarks:«MDNM» MDUL = printed, not cursive, script. 5 and end: literally "andend"
366-001A   $$«MDBO»Sic:«MDNM» 32 «MDUL»partiam«MDNM»   36 Os «MDUL»petrosum«MDNM»   40 sufferrers   42 fortnigt
366-001A   $$«MDBO»To check:«MDNM» --
^Z
EOF

    result = @parser.parseFootNotes
    puts @parser.parse
  end

  def testParseSubset

    # No 366
    ['613-0653', '006-14A7', '006-20L4', '006-!9D-', '006-!9L1', '006-D540', '261-008D', '391-02U1', '553-1951', '357-27L2'].each do |fileName|
      #['613-0653', '006-14A7', '006-20L4', '006-!9D-', '006-!9L1', '006-D540', '261-008D', '391-02U1', '357-27L2'].each do |fileName|
      #['613-0653', '006-14A7', '006-20L4', '006-!9D-', '006-!9L1', '006-D540', '261-008D', '357-27L2'].each do |fileName|

      parser = SPPParser.new(fileName)
      puts parser.parse
    end
  end
end
