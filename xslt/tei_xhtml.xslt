<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:tei="http://www.tei-c.org/ns/1.0"
		xml:lang="en">

  <!--
     * @file Stylesheet for the transformation of TEI documents into HTML snippets
     * @author griffinj@lafayette.edu
     *
    -->

  <!-- TEI <gap> elements -->

  <!-- Resolves SPP-535 -->
  <xsl:template match="tei:gap[@reason]">

    <span class="swift-tei-html-gap"> (<xsl:value-of select="@reason" />)</span>
  </xsl:template>

  <xsl:template match="tei:gap">

    <span class="swift-tei-html-gap">(omitted)</span>
  </xsl:template>

  <!--
     * TEI line breaks
    -->
  <xsl:template match="tei:lb">

    <br />
  </xsl:template>

  <!--
     * TEI Rendering Styles
    -->
  <xsl:template match="tei:hi[@rend='sup underline']">
    
    <sup class="swift-tei-html-superscript-underlined">

      <xsl:apply-templates />
    </sup>
  </xsl:template>

  <!--
     * TEI Superscript Rendering Style
    -->
  <xsl:template match="tei:hi[@rend='sup']">
    
    <sup>

      <xsl:apply-templates />
    </sup>
  </xsl:template>

  <!--
     * TEI Bold Rendering Style
     * @todo Discuss the architecture and implementation with @goodnowt
    -->
  <xsl:template match="tei:hi[@rend='underline']">
    
    <i>

      <xsl:apply-templates />
    </i>
  </xsl:template>

  <!-- TEI Display Initial Rendering Style -->
  <xsl:template match="tei:hi[@rend='display-initial']">
    
    <span class="swift-tei-html-display-initial">

      <xsl:apply-templates />
    </span>
  </xsl:template>

  <!-- TEI Small Capital Rendering Style -->
  <xsl:template match="tei:hi[@rend='SMALL-CAPS']">
    
    <span class="swift-tei-html-small-caps">

      <xsl:apply-templates />
    </span>
  </xsl:template>

  <!-- Lafayette-DSS Blackletter Rendering Style -->
  <xsl:template match="tei:hi[@rend='blackletter']">
    
    <span class="swift-tei-html-blackletter">

      <xsl:apply-templates />
    </span>
  </xsl:template>

  <!-- TEI Footnotes -->

  <!-- Resolves SPP-535 -->
  <xsl:template match="tei:ref[@target]">
    <!-- No-op -->
    <span class="swift-tei-html-footnote-reference"/>
  </xsl:template>

  <!-- Render TEI footnotes at the bottom of the page -->
  <xsl:template name="footnotes">

    <xsl:param name="footnote-index" />

    <xsl:for-each select="//tei:note[@place='foot']">
      <div class="swift-tei-html-footnote">
      
	<!-- Replace <tei:note> children of <tei:title> elements with footnote numbers -->
	<div class="swift-tei-html-footnote-number-container">
	<sup class="swift-tei-html-footnote-number">
	  
	  <xsl:value-of select="@n" />
	</sup>
	</div>

	<!--
	   Please note that the 7th edition of the MLA Handbook does not specify explicitly how to fully format footnotes, at least not when compared to the prescriptions in the 6th  edition. Consult your instructor to see what his or her preference is when formatting footnotes in MLA style.

	   The following comes from the 6th and 7th editions. The 6th edition of the MLA Handbook contains information on how to format footnotes, however. Begin footnotes four lines (two double-spaced lines) below the main text. Footnotes are double-space with a first-line indent. (The first line of each footnote is indented five spaces; subsequent lines are flush with the left margin.) Place a period and a space after each footnote number. Provide the appropriate note after the space.
	   -->
	<xsl:text> </xsl:text>

	<div class="swift-tei-html-footnote-content">
	  
	  <xsl:apply-templates />
	</div>
      </div>
    </xsl:for-each>
  </xsl:template>

  <!--
     * Render inline TEI sic notes
     * @todo Discuss the architecture and implementation with @goodnowt
     *
    -->
  <xsl:template match="tei:note[@type='sic']">

    <!-- @todo Implement -->
  </xsl:template>


  <!-- Render inline TEI footnotes with simply the footnote index -->
  <xsl:template match="tei:note[@place='foot']">

    <xsl:param name="footnote-number" select="2" />

    <!-- Replace <tei:note> children of <tei:title> elements with footnote numbers -->
    <sup class="swift-tei-html-footnote-number">
      
      <xsl:value-of select="@n" />
    </sup>

    <!--
       Please note that the 7th edition of the MLA Handbook does not specify explicitly how to fully format footnotes, at least not when compared to the prescriptions in the 6th  edition. Consult your instructor to see what his or her preference is when formatting footnotes in MLA style.
       
       The following comes from the 6th and 7th editions. The 6th edition of the MLA Handbook contains information on how to format footnotes, however. Begin footnotes four lines (two double-spaced lines) below the main text. Footnotes are double-space with a first-line indent. (The first line of each footnote is indented five spaces; subsequent lines are flush with the left margin.) Place a period and a space after each footnote number. Provide the appropriate note after the space.
      -->
    <xsl:text> </xsl:text>

  </xsl:template>

  <!-- TEI lines -->
  <xsl:template match="tei:l">

    <!-- Render each TEI <l> as a <div> -->
    <div class="swift-tei-html-line-container">

      <!-- Handling the l['rend'] values -->
      <xsl:if test="@rend">
	<xsl:choose>
	  <xsl:when test="starts-with(@rend, 'indent')">

	    <xsl:attribute name="class">

	      <xsl:value-of select="concat('swift-tei-html-line-container indent-', substring-before(substring(@rend, 8), ')'))" />
	    </xsl:attribute>
	  </xsl:when>
	</xsl:choose>
      </xsl:if>

      <!-- Render each TEI l['n'] value as <span> element content -->
      <xsl:if test="not (tei:head)">

	<div class="swift-tei-html-line-number">

	  <xsl:value-of select="@n" />
	</div>
      </xsl:if>
      
      <!-- Render each TEI l['n'] value as the span['id'] value -->
      <div class="swift-tei-html-line">
	
	<xsl:attribute name="id">
	  <xsl:value-of select="@n" />
	</xsl:attribute>
	
	<xsl:choose>
	  <xsl:when test="starts-with(@rend, 'underline')">

	    <!-- @todo Replace with more accurate element and handle with styling -->
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
    <div class="swift-tei-html-line-container">

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
	<span class="swift-tei-html-line-number">

	  <xsl:value-of select="@n" />
	</span>
      </xsl:if>
      
      <!-- Render each TEI l['n'] value as the span['id'] value -->
      <div class="swift-tei-html-line">
	
	<xsl:attribute name="id">
	  <xsl:value-of select="@n" />
	</xsl:attribute>
	
	<xsl:choose>
	  <xsl:when test="starts-with(@rend, 'underline')">

	    <!-- @todo Replace with more accurate element and handle with styling -->
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

    <div class="swift-tei-html-stanza">

      <xsl:attribute name="id">
	<xsl:value-of select="@n" />
      </xsl:attribute>

      <xsl:apply-templates />
    </div>
  </xsl:template>

  <!-- Resolves SPP-535 -->
  <xsl:template match="tei:head/tei:lg/tei:l">
    <p>

      <xsl:apply-templates />
    </p>
  </xsl:template>

  <xsl:template match="tei:head">

    <h2 class="swift-tei-html-header-headnote" role="banner">
      <p>
      <!--
	 There are multiple headers within James Woolley's Nota Bene documents
	 I have mapped these to multiple TEI P5 <head/> elements; this may not be the ideal implementation
      -->

      <!-- Disable headnote line numbering -->
      <!--
      <xsl:attribute name="id">
	<xsl:value-of select="@n" />
      </xsl:attribute>
      -->

      <xsl:apply-templates />
      </p>
    </h2>
  </xsl:template>

  <!-- Rendering all <tei:title> elements -->
  <xsl:template match="tei:title">
  
    <h1 class="swift-tei-html-header-header">
      <p>

      <xsl:apply-templates />

      <!--
	 * Render all <tei:note /> elements
	 * @todo Discuss the architecture and implementation with @goodnowt
	 *
	-->
      <!-- <xsl:apply-templates select="text() | *[not(self::tei:note)]" /> -->
      </p>
    </h1>
  </xsl:template>

  <!-- TEI text body blocks -->

  <!-- For individual letters -->
  <xsl:template match="tei:div[@type='letter']/tei:div">

    <div class="swift-tei-html-paragraph">
      
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="tei:div[@type='letter']">

    <div class="swift-tei-html-letter">

      <xsl:attribute name="id">
	<xsl:value-of select="@n" />
      </xsl:attribute>

      <xsl:apply-templates />
    </div>
  </xsl:template>

  <!-- For individual poems -->
  <xsl:template match="tei:div[@type='poem']">

    <div class="swift-tei-html-poem">

      <xsl:attribute name="id">

	<xsl:value-of select="@n" />
      </xsl:attribute>

      <xsl:apply-templates />
    </div>
  </xsl:template>

  <!-- TEI <book> elements within all collections -->
  <xsl:template match="tei:div[@type='book']">

    <div class="swift-tei-html-book">

      <!-- @todo Extend for more complex rendering? -->
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <!-- TEI Header -->
  <xsl:template match="tei:encodingDesc">

    <div class="swift-tei-html-encoding-notes">

      <div class="swift-tei-html-normalization-notes">

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

    <address class="swift-tei-html-attribution">
      Attributed to:<span><xsl:apply-templates /></span>
    </address>
  </xsl:template>

  <!-- Rendering all titles for a given poem or letter -->
  <xsl:template match="tei:fileDesc/tei:titleStmt">

    <!-- On 06/12/14, <hgroup> was still not widely compatible -->
    <div class="swift-tei-html-titles">
      
      <xsl:apply-templates select="tei:title" />
    </div>

    <xsl:apply-templates select="tei:author" />
  </xsl:template>

  <!-- The <article> wrapper for the HTML snippet -->
  <xsl:template match="tei:TEI">

      <article class="swift-tei-html" id="swift-tei-html-{tei:text/tei:body/tei:div[1]/tei:div[1]/@n}">

	<!-- Should each of these <div> elements be restructured with <section> elements? (I would avoid this as the TEI body and footer likely lack <h*> child elements) -->
	<header class="header swift-tei-html-header">

	  <xsl:apply-templates select="tei:teiHeader/tei:fileDesc/tei:titleStmt">

	    <xsl:with-param name="footnote-index" select="$footnote-index" />
	  </xsl:apply-templates>
	</header>

	<div class="swift-tei-html-body">

	<xsl:apply-templates select="tei:text/tei:body">

	  <xsl:with-param name="footnote-index" select="$footnote-index" />
	</xsl:apply-templates>
	</div>

	<footer class="swift-tei-html-footer">
	<xsl:call-template name="footnotes">

	  <xsl:with-param name="footnote-index" select="$footnote-index" />
	</xsl:call-template>
	</footer>
      </article>
  </xsl:template>
  <xsl:variable name="footnote-index" select="5" />
</xsl:stylesheet>
