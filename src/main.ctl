<?xml version="1.0" encoding="UTF-8"?>
<ctl:package
 xmlns="http://www.w3.org/2001/XMLSchema"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:ctl="http://www.occamlab.com/ctl"
 xmlns:parsers="http://www.occamlab.com/te/parsers"
 xmlns:myparsers="http://teamengine.sourceforge.net/parsers"
 xmlns:saxon="http://saxon.sf.net/"
 xmlns:wfs="http://www.opengis.net/wfs" 
 xmlns:sf="http://cite.opengeospatial.org/gmlsf" 
 xmlns:ows="http://www.opengis.net/ows"
 xmlns:xi="http://www.w3.org/2001/XInclude"
 xmlns:xlink="http://www.w3.org/1999/xlink"  
 xmlns:xsd="http://www.w3.org/2001/XMLSchema">

	<xi:include href="functions.ctl"/>
	<xi:include href="parsers.ctl"/>
	<xi:include href="readiness-tests.ctl"/>
	<xi:include href="basic/basic-main.xml"/>
	<xi:include href="wfs-transaction/transaction-tests.ctl"/>
	<xi:include href="wfs-xlink/xlink-main.xml"/>
	
	<ctl:suite name="ctl:wfs-1.1.0-compliance-suite" version="1.1.0.2-M1">
		  <ctl:title>WFS 1.1.0 Compliance Test Suite (1.1.0.2-M1)</ctl:title>
		  <ctl:description>Verifies that a WFS 1.1.0 implementation complies with a given conformance class.</ctl:description>
          <ctl:link>docs/wfs/1.1.0/</ctl:link>
          <ctl:link>data/data-wfs-1.1.0.zip</ctl:link>
		  <ctl:starting-test>wfs:wfs-main</ctl:starting-test>
           <ctl:form xmlns="" >
              <body>
                 <h2>Compliance test suite for Web Feature Service (WFS) 1.1.0</h2>
                 <h3>Service metadata</h3>
                 <p>
                 Please provide a URL from which a capabilities document can 
                 be retrieved. Modify the URL template below to specify the 
                 location of an OGC capabilities document for the WFS implementation 
                 under test (this can refer to a static document or to a service endpoint).
                 </p>
                 <p>Examples of reference implementations that can be tested can be found at the <a href="http://cite.opengeospatial.org/reference">CITE wiki</a>.</p>
                 <blockquote>
                    <table border="1" padding="4" bgcolor="#00ffff">
                       <tr>
                          <td align="left">Capabilities URL:</td>                        
                          <td align="center">
                             <input name="capabilities-url" size="128" 
                             type="text" 
                             value="http://hostname:port/path?query"/>
                          </td>
                       </tr>
                    </table>
                 </blockquote>
			  
                 <h3>Supported conformance classes</h3>
                 <p>
                 A conformance class denotes a set of functional capabilities provided by the WFS under test.
                 </p>
                 <blockquote>
                    <table border="1" frame="box" padding="4" bgcolor="#00ffff">
                       <tr>
                          <td align="center"></td>
                          <td align="left"><strong>WFS-Basic</strong> (Required) : Implements <em>GetCapabilities</em>, <em>DescribeFeatureType</em> and <em>GetFeature</em> requests</td>
                       </tr>
                       <tr>
                          <td align="center">
                             <input name="wfs-transaction" type="checkbox" value="Transaction" />
                          </td>
                          <td align="left"><strong>WFS-Transaction</strong> : Implements the <em>Transaction</em> request (<em>LockFeature</em> and <em>GetFeatureWithLock</em> are optional)</td>
                       </tr>
                       <tr>
                          <td align="center">
                             <input name="wfs-xlink" type="checkbox" value="XLink" />
                          </td>
                          <td align="left"><strong>WFS-XLink</strong> : Implements the <em>GetGmlObject</em> request and supports (local) XLink processing in GetFeature requests.</td>
                       </tr>
                    </table>
                 </blockquote>
			  <br/>
			  
                 <h3>GML Simple Features (GMLSF) compliance level</h3>
                 <p>
                 This indicates the scope of GML 3.1 support, as documented in OGC 06-049.  
                 Test data for levels SF-0 and SF-1 are currently available.  This setting is 
                 ignored when assessing XLink conformance because it requires support 
                 at the SF-2 level.
                 </p>
                 <blockquote>
                    <table border="1" padding="4" bgcolor="#00ffff">
                       <tr>
                          <td align="center">
                             <input name="profile" type="radio" value="sf-0" checked="checked"/>
                          </td>
                          <td align="left">SF-0 : Level 0 (only simple non-spatial property types; Curve and Surface geometries are excluded)</td>
                       </tr>
                       <tr>
                          <td align="center">
                             <input name="profile" type="radio" value="sf-1"/>
                          </td>
                          <td align="left">SF-1 : Level 1 (complex non-spatial property types, plus Curve and Surface geometries)</td>
                       </tr>
                    </table>
                 </blockquote>
			  <p>
                 <div bgcolor="#ffffcc"><strong> WARNING </strong> Don't forget to add the test data!</div>
                 </p>
                 <br />
                 <input type="submit" value="Start"/>
              </body>
           </ctl:form>

	</ctl:suite>

   <ctl:test name="wfs:wfs-main">
      <ctl:param name="capabilities-url"/>
      <ctl:param name="wfs-transaction"/>
      <ctl:param name="wfs-xlink"/>
      <ctl:param name="profile"/>
      <ctl:assertion>WFS 1.1.0 Tests</ctl:assertion>
      <ctl:code>

		<!-- Get user input: -->
		<xsl:variable name="wfs.GetCapabilities.get.url" select="$capabilities-url"/>
		<xsl:variable name="gmlsf.profile.level" select="$profile"/>

		<!--TODO: Get GMLSF profile level from DescribeFeatureType and XPath expression (gmlsf conformance level 0 or 1) rather than user input-->

		<!-- Attempt to retrieve capabilities document -->
 
		<xsl:variable name="wfs.GetCapabilities.document">
			<ctl:request>
				<ctl:url>
					<xsl:value-of select="$wfs.GetCapabilities.get.url"/>
				</ctl:url>
				<ctl:method>GET</ctl:method>
			</ctl:request>
		</xsl:variable>	

		 <!-- Call the readiness tests, which then call the conformance class tests -->
		 <xsl:choose>
				<xsl:when test="not($wfs.GetCapabilities.document//wfs:WFS_Capabilities)">
					<ctl:message>FAILURE: Did not receive a wfs:WFS_Capabilities document! Skipping remaining tests.</ctl:message>	
					<ctl:fail/>
				</xsl:when>
				<xsl:otherwise>
					<!-- Ingest initial test data -->
					<!-- <xsl:variable name="ingest.data" select="$wfs-transaction"/>
					<xsl:if test="string-length($ingest.data) gt 0">				
						<ctl:call-test name="wfs:ingest-test-data">
							<ctl:with-param name="wfs.GetCapabilities.document" select="$wfs.GetCapabilities.document"/>
							<ctl:with-param name="gmlsf.profile.level" select="$gmlsf.profile.level"/>
						</ctl:call-test>
					</xsl:if> -->
					<ctl:call-test name="wfs:readiness-tests">
						<ctl:with-param name="wfs.GetCapabilities.document" select="$wfs.GetCapabilities.document"/>														
						<ctl:with-param name="wfs-transaction" select="$wfs-transaction"/>
                        <ctl:with-param name="wfs-xlink" select="$wfs-xlink"/>
						<ctl:with-param name="gmlsf.profile.level" select="$gmlsf.profile.level"/>	
					</ctl:call-test>
 					
				</xsl:otherwise>
		 </xsl:choose>
      </ctl:code>
   </ctl:test>	

	<!--<ctl:test name="wfs:ingest-test-data">
		<ctl:param name="wfs.GetCapabilities.document"/>
		<ctl:param name="gmlsf.profile.level"/>	
		<ctl:assertion>Ingests the mandatory test data for use by the test suite.</ctl:assertion>
		<ctl:comment>Uses Transaction Inserts to load all WFS 1.1.0 test data into a service. The data must be relative to this file in "./data/wfs/1.1.0/sf-X/dataset-sfX-insert.xml", where "X" is the GMLSF level.</ctl:comment>
		<ctl:code>
			
		  <xsl:variable name="wfs.Transaction.post.url">
			<xsl:value-of select="$wfs.GetCapabilities.document//ows:OperationsMetadata/ows:Operation[@name='Transaction']/ows:DCP/ows:HTTP/ows:Post/@xlink:href"/>
		  </xsl:variable>

			<xsl:variable name="transaction.response.1">
				<ctl:request>
					<ctl:url>
						<xsl:value-of select="$wfs.Transaction.post.url"/>
					</ctl:url>
					<ctl:method>POST</ctl:method>
					<ctl:body>
						<xi:include href="../data/sf-0/dataset-sf0-insert.xml"/>
					</ctl:body>
				</ctl:request>
			</xsl:variable>
			
			<xsl:variable name="transaction.response.2">
				<ctl:request>
					<ctl:url>
						<xsl:value-of select="$wfs.Transaction.post.url"/>
					</ctl:url>
					<ctl:method>POST</ctl:method>
					<ctl:body>
						<xi:include href="../data/sf-1/dataset-sf1-insert.xml"/>
					</ctl:body>
				</ctl:request>
			</xsl:variable>
			
			<xsl:variable name="transaction.response.3">
				<ctl:request>
					<ctl:url>
						<xsl:value-of select="$wfs.Transaction.post.url"/>
					</ctl:url>
					<ctl:method>POST</ctl:method>
					<ctl:body>
						<xi:include href="../data/sf-2/dataset-sf2-insert.xml"/>
					</ctl:body>
				</ctl:request>
			</xsl:variable>

		</ctl:code>
	</ctl:test>-->
	
</ctl:package>

