<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output method="html" indent="yes"/>

	<xsl:template match="/action-plan">
		<h1>
			<xsl:value-of select="@format" /> - <xsl:value-of select="@format-version"/>
			Action Plan
		</h1>

		<h4>implementation-date : 
			<xsl:apply-templates select="implementation-date"/>
		</h4>

		<h4>revision-date : 
			<xsl:apply-templates select="revision-date"/>
		</h4>

		<h4>review-date : 
			<xsl:apply-templates select="review-date"/>
		</h4>
		
		<h4>next-review : 
			<xsl:apply-templates select="next-review"/>
		</h4>
		<hr/>

		<h3>Ingest Processing</h3>
		<dl class="ingest-processing">
			<xsl:apply-templates select="ingest-processing/*"/>
		</dl>
		<hr/>

		<h3>Significant Properties</h3>
		<dl class="significatn-properties">
			<xsl:apply-templates select="significant-properties/*"/>
		</dl>
		<hr/>

		<h3>Long-term Preservation Strategy</h3>
		<dl class="long-term-strategy">
			<xsl:apply-templates select="long-term-strategy/*"/>
		</dl>
		<hr/>

		<h3>Short-term Actions</h3>
		<ul class="short-term-actions">
			<xsl:apply-templates select="short-term-actions/*"/>
		</ul>

		<xsl:if test="note">
			<hr/>
			<h4>Note</h4>
			<p class="note">
				<xsl:value-of select="note"/>
			</p>

		</xsl:if>

	</xsl:template>

	<xsl:template match="identification|validation|characterization|migration">
		<dt><xsl:value-of select="name()"/></dt>
		<dd><xsl:value-of select="text()"/></dd>
	</xsl:template>

	<xsl:template match="normalization">
		<dt><xsl:value-of select="name()"/></dt>
		<dd><xsl:value-of select="text()"/></dd>
		<dd>
	    <xsl:if test="boolean(VideoStreams)">
		<br/>		
		<xsl:value-of select="VideoStreams/text()"/>
		<table border="1">
			<caption>Supported Video Stream Format</caption>
			<tr>
		      <th>Supported Video Stream Format</th>
		      <th>FOURCC</th>
		      <th>Normalized Video Stream</th>		
		    </tr>
			<xsl:for-each select="VideoStreams/stream">
				<tr>
					<td><xsl:value-of select="format"/></td>
					<td><xsl:value-of select="code"/></td>
					<td><xsl:value-of select="normalized-stream"/></td>
				</tr>
			</xsl:for-each>
		</table>
   	    </xsl:if>
	    </dd>
		<dd>
		<xsl:if test="boolean(AudioStreams)">
		<br/>
		<xsl:value-of select="AudioStreams/text()"/>
		<table border="1">
			<tr>
		      <th>Supported Audio Stream Format</th>
		      <th>Format Tag</th>
		      <th>Normalized Audio Stream</th>		
		    </tr>
			<xsl:for-each select="AudioStreams/stream">
				<tr>
					<td><xsl:value-of select="format"/></td>
					<td><xsl:value-of select="code"/></td>
					<td><xsl:value-of select="normalized-stream"/></td>
				</tr>
			</xsl:for-each>
		</table>
	    </xsl:if>
	    </dd>	
	</xsl:template>
	<xsl:template match="content|context|behavior|structure|appearance">
			<dt><xsl:value-of select="name()"/></dt>
			<dd><xsl:value-of select="text()"/></dd>
	</xsl:template>

	<xsl:template match="original|migrated|normalized">
		<dt><xsl:value-of select="name()"/></dt>
		<dd><xsl:value-of select="text()"/></dd>
		<dd><xsl:if test="boolean(normalized-video)">
			Video Stream: <xsl:value-of select="normalized-video/text()"/>
			</xsl:if>
		</dd>
		<dd><xsl:if test="boolean(normalized-audio)">
			Audio Stream: <xsl:value-of select="normalized-audio/text()"/>
			</xsl:if>
		</dd>
	</xsl:template>

	<xsl:template match="action">
			<li><xsl:value-of select="text()"/></li>
	</xsl:template>


</xsl:stylesheet>