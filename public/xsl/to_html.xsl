<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:template match="/action-plan">
		<html>
			<head>
				<title>Cascading Style Sheet</title>
				<link rel="stylesheet" type="text/css" href="/css/plan.css" 
					title="Style"/>
				</head>
				<body>
					<div id = "content">
						<!-- Banner -->
						<div id = "header">
							<h1>Action Plan: <xsl:value-of select="@format" />  <xsl:value-of select="@format-version"/></h1>
							<br/><hr/><br/>
							<h4>Implementation Date : <xsl:apply-templates select="implementation-date"/></h4>
							<h4>Revision Date : <xsl:apply-templates select="revision-date"/></h4>
							<h4>Review Date : <xsl:apply-templates select="review-date"/></h4>
							<h4>Next Review : <xsl:apply-templates select="next-review"/></h4>
							<br/>
						</div>

		 				<h3>Ingest Processing</h3>
						<ul class="ingest-processing">
							<xsl:apply-templates select="ingest-processing/*"/>
						</ul>
						<br/>
						<h3>Significant Properties</h3>
						<p><xsl:value-of select="significant-properties/text()"/></p>
						<ul class="significatn-properties">
							<xsl:apply-templates select="significant-properties/*"/>
						</ul>

						<br/>
						<h3>Long-term Preservation Strategy</h3>
						<div id="preserved">
							<xsl:apply-templates select="long-term-strategy/*"/>
						</div>

						<br/>
						<h3>Short-term Actions</h3>
						<ul class="short-term-actions">
							<xsl:apply-templates select="short-term-actions/*"/>
						</ul><br/>
						<xsl:if test="boolean(note)">
							<h3>Note</h3>
							<p><xsl:value-of select="note/text()"/></p>
						</xsl:if>										
						<div id="footer">
								<p align = 'center'><xsl:value-of select="footnote"/></p>
						</div>
					</div>
				</body>	
			</html>
		</xsl:template>
		
		<xsl:template match="identification|validation|characterization|migration|xmlresolution">
			<li><xsl:value-of select="name()"/>: <xsl:value-of select="text()"/></li>
		</xsl:template>

		<xsl:template match="normalization">
			<li><xsl:value-of select="name()"/>: <xsl:value-of select="text()"/></li>
			<dd>
				<xsl:if test="boolean(VideoStreams)">
					<br/>		
					<em><xsl:value-of select="VideoStreams/text()"/></em>
					<table>
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
					<em><xsl:value-of select="AudioStreams/text()"/></em>
					<table>
						<caption>Supported Audio Stream Format</caption>
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
			<li><xsl:value-of select="name()"/>: <xsl:value-of select="text()"/></li>
		</xsl:template>

		<xsl:template match="original|migrated">
			<h4>Long-term Preservation Strategy for the <xsl:value-of select="name()"/></h4>
			<p><xsl:value-of select="text()"/></p><br/>
		</xsl:template>

		<xsl:template match="normalized">
			<h4>Long-term Preservation Strategy for the <xsl:value-of select="name()"/></h4>
			<p><xsl:value-of select="text()"/></p><br/>
			<ul>
			<xsl:if test="boolean(normalized-video)">
				<li>Video Stream: <xsl:value-of select="normalized-video/text()"/></li>
			</xsl:if>
			
			<xsl:if test="boolean(normalized-audio)">
				<li>Audio Stream: <xsl:value-of select="normalized-audio/text()"/></li>
			</xsl:if>
			</ul>
		</xsl:template>
		
		<xsl:template match="action">
			<li><xsl:value-of select="text()"/></li>
		</xsl:template>

</xsl:stylesheet>