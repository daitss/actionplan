<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="html" indent="yes"/>

  <xsl:template match="/action-plan">
    <h1>
      <xsl:value-of select="@format"/>
      (<xsl:value-of select="@format-version"/>)
      Action Plan
    </h1>

	<h3>implementation-date : 
		<xsl:apply-templates select="implementation-date"/>
	</h3>


	<h3>revision-date : 
		<xsl:apply-templates select="revision-date"/>
	</h3>


	<h3>review-date : 
		<xsl:apply-templates select="review-date"/>
	</h3>
	
	<h3>next-review : 
		<xsl:apply-templates select="next-review"/>
	</h3>
    <hr/>

    <h2>Ingest Processing</h2>
    <dl class="ingest-processing">
      <xsl:apply-templates select="ingest-processing/*"/>
    </dl>

    <hr/>

    <h2>Significant Properties</h2>
    <dl class="significatn-properties">
      <xsl:apply-templates select="significant-properties/*"/>
    </dl>

    <hr/>

    <h2>Long-term Preservation Strategy</h2>
    <dl class="long-term-strategy">
      <xsl:apply-templates select="long-term-strategy/*"/>
    </dl>

    <hr/>

    <h2>Short-term Actions</h2>
    <ul class="short-term-actions">
      <xsl:apply-templates select="short-term-actions/*"/>
    </ul>

    <xsl:if test="note">

      <hr/>

      <h3>Note</h3>
      <p class="note">
        <xsl:value-of select="note"/>
      </p>

    </xsl:if>

  </xsl:template>

  <xsl:template match="identification|validation|characterization|localization">
    <dt><xsl:value-of select="name()"/></dt>
    <dd><xsl:value-of select="text()"/></dd>
  </xsl:template>

  <xsl:template match="migration|normalization">
    <dt><xsl:value-of select="name()"/></dt>
    <dd>
      <xsl:value-of select="text()"/>
    </dd>
  </xsl:template>

  <xsl:template match="content|context|behavior|structure|appearance">
    <dt><xsl:value-of select="name()"/></dt>
    <dd><xsl:value-of select="text()"/></dd>
  </xsl:template>

  <xsl:template match="original|migrated|normalized">
    <dt><xsl:value-of select="name()"/></dt>
    <dd><xsl:value-of select="text()"/></dd>
  </xsl:template>

  <xsl:template match="action">
    <li><xsl:value-of select="text()"/></li>
  </xsl:template>


</xsl:stylesheet>