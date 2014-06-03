<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:tei="http://www.tei-c.org/ns/1.0"
		xml:lang="en">

  <!-- TEI <gap> elements -->
  <xsl:template match="tei:gap">

    <span class="gap">(omitted)</span>
  </xsl:template>

  <!-- TEI line breaks -->
  <xsl:template match="tei:lb">

    <br />
  </xsl:template>

  <!-- TEI Rendering Styles -->
  <xsl:template match="tei:hi[@rend='sup underline']">
    
    <sup class="superscript-underlined">

      <xsl:apply-templates />
    </sup>
  </xsl:template>

  <!-- TEI Superscript Rendering Style -->
  <xsl:template match="tei:hi[@rend='sup']">
    
    <sup>

      <xsl:apply-templates />
    </sup>
  </xsl:template>

  <!-- TEI Bold Rendering Style -->
  <xsl:template match="tei:hi[@rend='underline']">
    
    <i>

      <xsl:apply-templates />
    </i>
  </xsl:template>

  <!-- TEI Display Initial Rendering Style -->
  <xsl:template match="tei:hi[@rend='display-initial']">
    
    <span class="display-initial">

      <xsl:apply-templates />
    </span>
  </xsl:template>

  <!-- TEI Small Capital Rendering Style -->
  <xsl:template match="tei:hi[@rend='SMALL-CAPS']">
    
    <span class="small-caps">

      <xsl:apply-templates />
    </span>
  </xsl:template>

  <!-- Lafayette-DSS Blackletter Rendering Style -->

  <xsl:template match="tei:hi[@rend='blackletter']">
    
    <span class="blackletter">

      <xsl:apply-templates />
    </span>
  </xsl:template>

  <!--
<teiHeader>
    <fileDesc>
      <titleStmt>
        <title>Dr Delany wrote to Dr Swift, in order<lb/>to be admitted to speak to him when he<lb/>was Deaf. to which the Dean sent the<lb/>following Answer.</title><sponsor>Lafayette College</sponsor>
        <principal>James Woolley</principal>
	<respStmt><name key="JW"/><resp>transcription</resp></respStmt><respStmt><resp>proof corrected</resp><resp>proof corrected</resp><name key="TNiese 25JA11"/></respStmt><author>
	-->


  <!-- TEI Footnotes -->

  <!-- Render TEI footnotes at the bottom of the page -->
  <xsl:template name="footnotes">

    <xsl:param name="footnote-index" />

    <xsl:for-each select="//tei:note[@place='foot']">
      <div class="footnote">
      
	<!-- Replace <tei:note> children of <tei:title> elements with footnote numbers -->
	<sup class="footnote-number">
	  
	  <xsl:value-of select="@n" />
	</sup>

	<!--
	   Please note that the 7th edition of the MLA Handbook does not specify explicitly how to fully format footnotes, at least not when compared to the prescriptions in the 6th  edition. Consult your instructor to see what his or her preference is when formatting footnotes in MLA style.

	   The following comes from the 6th and 7th editions. The 6th edition of the MLA Handbook contains information on how to format footnotes, however. Begin footnotes four lines (two double-spaced lines) below the main text. Footnotes are double-space with a first-line indent. (The first line of each footnote is indented five spaces; subsequent lines are flush with the left margin.) Place a period and a space after each footnote number. Provide the appropriate note after the space.
	   -->
	<xsl:text>&nbsp;</xsl:text>

	<div class="footnote-content">
	  
	  <xsl:apply-templates />
	</div>
      </div>
    </xsl:for-each>
  </xsl:template>


  <!-- Render inline TEI sic notes -->
  <xsl:template match="tei:note[@type='sic']">

    <!--
    <div class="sic-container">
      
      <xsl:apply-templates />
    </div>
    -->
    
  </xsl:template>


  <!-- Render inline TEI footnotes with simply the footnote index -->
  <xsl:template match="tei:note[@place='foot']">

    <xsl:param name="footnote-number" select="2" />

    <!-- Replace <tei:note> children of <tei:title> elements with footnote numbers -->

    <sup class="footnote-number">
      
      <xsl:value-of select="@n" />
    </sup>

    <!--
       Please note that the 7th edition of the MLA Handbook does not specify explicitly how to fully format footnotes, at least not when compared to the prescriptions in the 6th  edition. Consult your instructor to see what his or her preference is when formatting footnotes in MLA style.
       
       The following comes from the 6th and 7th editions. The 6th edition of the MLA Handbook contains information on how to format footnotes, however. Begin footnotes four lines (two double-spaced lines) below the main text. Footnotes are double-space with a first-line indent. (The first line of each footnote is indented five spaces; subsequent lines are flush with the left margin.) Place a period and a space after each footnote number. Provide the appropriate note after the space.
      -->
    <xsl:text>&nbsp;</xsl:text>

  </xsl:template>

  <!-- TEI lines -->
  <xsl:template match="tei:l">

    <!-- Render each TEI <l> as a <div> -->
    <!--
    <div class="swift-poems-project line-container">
      -->
    <div>

      <!-- Handling the l['rend'] values -->
      <xsl:if test="@rend">
	<xsl:choose>
	  <xsl:when test="starts-with(@rend, 'indent')">
	    <!--
	    <xsl:attribute name="indent">
	      -->
	    <xsl:attribute name="class">
	      <!--
	      <xsl:value-of select="substring-before(substring(@rend, 8), ')')" />
	      -->
	      <xsl:value-of select="concat('line-container indent-', substring-before(substring(@rend, 8), ')'))" />
	    </xsl:attribute>
	  </xsl:when>

	</xsl:choose>
      </xsl:if>

      <!-- Render each TEI l['n'] value as <span> element content -->

      <xsl:if test="not (tei:head)">

	<span class="line-number">
	  <xsl:value-of select="@n" />
	</span>
      </xsl:if>
      
      <!-- Render each TEI l['n'] value as the span['id'] value -->
      <div class="line">
	
	<xsl:attribute name="id">
	  <xsl:value-of select="@n" />
	</xsl:attribute>
	
	<xsl:choose>
	  <xsl:when test="starts-with(@rend, 'underline')">

	    <b>
	      <xsl:apply-templates />
	    </b>

	  </xsl:when>
	  <xsl:otherwise>
	    
	    <xsl:apply-templates />
	  </xsl:otherwise>

	</xsl:choose>

      </div>

    </div>
  </xsl:template>

  <!-- Lines within a letter -->
  <xsl:template match="tei:p">

    <!-- Render each TEI <l> as a <div> -->
    <div class="line-container">

      <!-- Handling the l['rend'] values -->
      <xsl:if test="@rend">
	<xsl:choose>
	  <xsl:when test="starts-with(@rend, 'indent')">
	    <xsl:attribute name="indent">
	      <xsl:value-of select="substring-before(substring(@rend, 8), ')')" />
	    </xsl:attribute>
	  </xsl:when>
	</xsl:choose>
      </xsl:if>

      <xsl:if test="not (tei:head)">

	<!-- Render each TEI l['n'] value as <span> element content -->
	<span class="line-number">

	  <xsl:value-of select="@n" />
	</span>
      </xsl:if>
      
      <!-- Render each TEI l['n'] value as the span['id'] value -->
      <div class="line">
	
	<xsl:attribute name="id">
	  <xsl:value-of select="@n" />
	</xsl:attribute>
	
	<xsl:choose>
	  <xsl:when test="starts-with(@rend, 'underline')">

	    <b>
	      <xsl:apply-templates />
	    </b>

	  </xsl:when>
	  <xsl:otherwise>
	    
	    <xsl:apply-templates />
	  </xsl:otherwise>

	</xsl:choose>

      </div>

    </div>
  </xsl:template>


  <xsl:template match="tei:lg[@type='stanza']">

    <div class="stanza">

      <xsl:attribute name="id">
	<xsl:value-of select="@n" />
      </xsl:attribute>

      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="tei:head">

    <h2 class="headnote">

      <!--
	 There are multiple headers within James Woolley's Nota Bene documents
	 I have mapped these to multiple TEI P5 <head/> elements; this may not be the ideal implementation
      -->
      <xsl:attribute name="id">
	<xsl:value-of select="@n" />
      </xsl:attribute>

      <xsl:apply-templates />
    </h2>
  </xsl:template>

  <!-- Rendering all <tei:title> elements -->
  <xsl:template match="tei:title">
  
    <h1 class="title">

      <xsl:apply-templates />

      <!-- Ignore all <tei:note /> elements -->
      <!--
      <xsl:apply-templates select="text() | *[not(self::tei:note)]" />
      -->

    </h1>
  </xsl:template>

  <!-- TEI text body blocks -->

  <!-- For individual letters -->
  <xsl:template match="tei:div[@type='letter']/tei:div">

    <div class="paragraph">
      
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="tei:div[@type='letter']">

    <div class="letter">

      <xsl:attribute name="id">
	<xsl:value-of select="@n" />
      </xsl:attribute>

      <xsl:apply-templates />
    </div>
  </xsl:template>

  <!-- For individual poems -->
  <xsl:template match="tei:div[@type='poem']">

    <div class="poem">

      <xsl:attribute name="id">
	<xsl:value-of select="@n" />
      </xsl:attribute>

      <xsl:apply-templates />
    </div>
  </xsl:template>

  <!-- TEI <book> elements within all collections -->
  <xsl:template match="tei:div[@type='book']">

    <div class="book">
      
      <!--
      <xsl:apply-templates select="tei:titleStmt"/>
      -->

      <xsl:apply-templates />
    </div>
  </xsl:template>

  <!-- TEI Header -->

  <xsl:template match="tei:encodingDesc">

    <div class="encoding-notes">

      <div class="normalization-notes">

	<xsl:for-each select="tei:editorialDecl/tei:normalization">
	  <p>
	    <xsl:value-of select="." />
	  </p>
	</xsl:for-each>
      </div>
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <!-- Rendering Note Bene notes -->

  <xsl:template match="tei:author">

    <div class="attribution">

      Attributed to:<span><xsl:apply-templates /></span>
    </div>
  </xsl:template>

  <xsl:template match="tei:fileDesc/tei:titleStmt">

    <div class="titles">
      
      <xsl:apply-templates select="tei:title" />
    </div>

    <xsl:apply-templates select="tei:author" />
  </xsl:template>

  <xsl:output method="xml"
	      version="1.0"
	      encoding="UTF-8"
	      doctype-public="-//W3C//DTD XHTML 1.1//EN"
	      doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"
	      indent="yes" />

  <!-- <xsl:template match="tei:text"> -->
  <xsl:template match="tei:TEI">

    <html xmlns="http://www.w3.org/1999/xhtml">

      <head>
	<title>

	  <!--
teiHeader>
    <fileDesc>
      <titleStmt>
        <title>
	      -->
	  <xsl:choose>

	    <xsl:when test="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/*">
	      <!-- Rendering the title for the Document within the HTML <title/> element -->
	      <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/* | tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/text()">

		<xsl:choose>
		  
		  <xsl:when test="name()='lb'">
		    
		    <xsl:text> </xsl:text>
		  </xsl:when>
		  <xsl:otherwise>
		    
		    <xsl:value-of select="." />
		  </xsl:otherwise>
		</xsl:choose>
	      </xsl:for-each>
	    </xsl:when>

	    <xsl:when test="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title">

	      <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title" />
	    </xsl:when>

	    <xsl:otherwise>(Untitled)</xsl:otherwise>
	  </xsl:choose>
	</title>
	
	<!-- Within production, CSS styling will either be removed or retrieved dynamically from a Fedora Common Object Datastream -->
	<link href="../../css/doc.css" rel="stylesheet" type="text/css" media="all" />
      </head>
      <body>

	<div class="header">

	  <!--
	  <xsl:apply-templates select="tei:teiHeader/tei:fileDesc/tei:titleStmt" />
	  -->
	  <xsl:apply-templates select="tei:teiHeader/tei:fileDesc/tei:titleStmt">

	    <xsl:with-param name="footnote-index" select="$footnote-index" />
	  </xsl:apply-templates>
	</div>

	<!--
	<xsl:apply-templates select="tei:text/tei:body" />
	-->
	<xsl:apply-templates select="tei:text/tei:body">

	  <xsl:with-param name="footnote-index" select="$footnote-index" />
	</xsl:apply-templates>

	<hr />

	<xsl:call-template name="footnotes">

	  <xsl:with-param name="footnote-index" select="$footnote-index" />
	</xsl:call-template>
      </body>

      <!-- For Unifraktur Blackletter rendering -->
      <link href="http://fonts.googleapis.com/css?family=UnifrakturCook:700" rel="stylesheet" type="text/css" />
    </html>
  </xsl:template>
  <xsl:variable name="footnote-index" select="5" />

  <!--
     <div type="book">
       <div n="366-001A" type="poem">
	 <head n="1">Written in the Year 1724.</head><lg type="stanza"><l rend="indent" n="1"/><l n="1">The wise pretend to make it clear,</l><l n="2"/><l n="2">'Tis no great loss to lose an ear.</l><l n="3"/><l n="3">Why are we then so fond of two,</l><l n="4"/><l n="4">When by experience one would do.</l></lg><lg type="stanza"><l rend="indent" n="1"/><l n="1">'Tis true, say they, cut off the head,</l><l n="6"/><l n="6">And there's and end, the man is dead;</l><l n="7"/><l n="7">Because among all human race,</l><l n="8"/><l n="8">None e'er was known to have a brace;</l><l n="9"/><l n="9">But confidently they maintain,</l><l n="10"/><l n="10">That where we find the Members twain,</l><l n="11"/><l n="11">The loss of one is no such trouble,</l><l n="12"/><l n="12">Since t'other will in Strength be double:</l><l n="13"/><l n="13">The limb Surviving you may swear,</l><l n="14"/><l n="14">Becomes his brothers lawful heir.</l><l n="15"/><l n="15">Thus for a trial let me beg of</l><l n="16"/><l n="16">Your Rev'rence but to cut one Leg off</l><l n="17"/><l n="17">And you shall find by this device</l><l n="18"/><l n="18">The other will be stronger twice.</l><l n="19"/><l n="19">For ev'ry day you shall be gaining</l><l n="20"/><l n="20">New Vigor to the leg remaining:</l><l n="21"/><l n="21">So when an Eye hath lost its Brother,</l><l n="22"/><l n="22">You see the better with the other:</l><l n="23"/><l n="23">Cut off your hand and you may do</l><l n="24"/><l n="24">With t'other hand the Work of two:</l><l n="25"/><l n="25">Because the Soul her pow'r Contracts,</l><l n="26"/><l n="26"></l><l rend="indent" n="27"/><l n="27">But yet the point is not so clear in</l><l n="28"/><l n="28">Another Case, the sense of hearing;</l><l n="29"/><l n="29">For tho' the place of either Ear</l><l n="30"/><l n="30">Be distant as one head can bear;</l><l n="31"/><l n="31">Yet Galen most acutely shews you</l><l n="32"/><l n="32"></l><l n="33"/><l n="33">That from each ear as he observes,</l><l n="34"/><l n="34">There crept two auditory nerves,</l><l n="35"/><l n="35">Not to be seen without a Glass,</l><l n="36"/><l n="36"></l><l n="37"/><l n="37">Thence to the Neck, and moving thorough there</l><l n="38"/><l n="38">One goes to this, and one to t'other ear.</l><l n="39"/><l n="39">Which made my grand-dame always stuff her Ears,</l><l n="40"/><l n="40">Both right and left as fellow sufferrers.</l><l n="41"/><l n="41">You see my Learning; but to shorten it,</l><l n="42"/><l n="42">When my left ear was deaf a fortnigt,</l><l n="43"/><l n="43">To t'other ear I felt it coming on</l><l n="44"/><l n="44"></l><l n="45"/><l n="45">Tis true a glass will bring supplies</l><l n="46"/><l n="46">To weak, or old, or clouded Eyes:</l><l n="47"/><l n="47">Your Arms, tho' both your eyes were lost,</l><l n="48"/><l n="48">Would guard your nose against a post:</l><l n="49"/><l n="49">Without your legs two Legs of Wood</l><l n="50"/><l n="50">Are stronger and almost as good:</l><l n="51"/><l n="51">And as for Hands there have been those,</l><l n="52"/><l n="52"/><l n="52"/><l n="52">Who wanting both, have us'd their Toes<note place="foot">There was about this Time a man shew'd who wrote with his foot.</note>;</l><l n="53"/><l n="53">But no Contrivance yet appears,</l><l n="54"/><l n="54">To furnish artificial Ears.</l></lg></div>
    </div>
-->


  <!-- <xsl:import href="teibp/teibp.xsl" /> -->
  <!-- <xsl:import href="/usr/share/stylesheets/tei/xhtml2/tei.xsl" />-->





  <!--
     <html>
       
       <body>
	 <xsl:if test="$includeToolbox = true()">
	   <xsl:call-template name="teibpToolbox"/>
	 </xsl:if>

	 <div id="tei_wrapper">
	   <xsl:apply-templates/>
	 </div>
	 
       </body>
     </html>
</xsl:template>
-->


</xsl:stylesheet>
