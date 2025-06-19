<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:v-on="http://example.com/xml/v-on">
	<xsl:output omit-xml-declaration="yes" indent="no"/>
    <xsl:output method="text"/>
    <xsl:strip-space elements="*"/>
	
	<xsl:template match="/">
		<xsl:variable name="selectedschema" select="Export/JSONschema"/>
		<xsl:call-template name="export-json-schema"><xsl:with-param name="theschema" select="$selectedschema"/></xsl:call-template>
	</xsl:template>

<!-- J S O N   S C H E M A   F O R   C O N C E P T -->
	<xsl:template name="export-json-schema">
		<xsl:param name="theschema"/>

		<xsl:variable name="theid" select="$theschema/StartDefinition"/>
		<xsl:variable name="thedefinition" select="//Definition[@NodeID=$theid]"/>
		<xsl:text>{"$schema": "</xsl:text><xsl:value-of select="$theschema/Schema"/><xsl:text>",</xsl:text>
		<xsl:text>"definitions": {</xsl:text>
		<xsl:for-each select="$theschema/Definitions/Definition">
			<xsl:call-template name="add-definition2json-schema"><xsl:with-param name="thedefinition" select="."/></xsl:call-template><xsl:if test="position() &lt; last()"><xsl:text>,</xsl:text></xsl:if>
		</xsl:for-each>
		<xsl:text>}, </xsl:text>
		<xsl:text>"type": "object",</xsl:text>
		<xsl:text>"properties": {"</xsl:text><xsl:value-of select="$thedefinition/Name"/><xsl:text>": {"$ref": "#/definitions/</xsl:text><xsl:value-of select="$thedefinition/Name"/><xsl:text>"}},</xsl:text>
		<xsl:text>"additionalProperties": false</xsl:text>
		<xsl:text>}</xsl:text>
	</xsl:template>

	<xsl:template name="add-definition2json-schema">
		<xsl:param name="thedefinition"/>
		<xsl:variable name="thepropertycount" select="count($thedefinition/PropertyGroup/Property)"/>
		<xsl:variable name="therelatedobjectcount" select="count($thedefinition/RelatedObjectGroup/RelatedObject)"/>
		<xsl:variable name="theruledobjectcount" select="count($thedefinition/RuledObjectGroup/RuledObjects/DefinitionRef)"/>
		<xsl:text>"</xsl:text><xsl:value-of select="$thedefinition/Name"/><xsl:text>": {</xsl:text>
			<xsl:text>"properties": {</xsl:text>
			<xsl:for-each select="$thedefinition/PropertyGroup/Property">
				<xsl:call-template name="add-property2json-schema"><xsl:with-param name="theproperty" select="."/></xsl:call-template><xsl:if test="position() &lt; last()">,</xsl:if>
			</xsl:for-each>
			<xsl:if test="($thepropertycount &gt; 0) and ($therelatedobjectcount &gt; 0)">,</xsl:if>
			<xsl:call-template name="add-arrays2json-schema"><xsl:with-param name="thedefinition" select="$thedefinition"/></xsl:call-template>
			<xsl:if test="not (($thepropertycount = 0) and ($therelatedobjectcount = 0)) and ($theruledobjectcount &gt; 0)">,</xsl:if>
			<xsl:call-template name="add-ruledobjects2json-schema"><xsl:with-param name="thedefinition" select="$thedefinition"/></xsl:call-template>
			<xsl:text>},</xsl:text>
			<xsl:text>"additionalProperties": false,</xsl:text>
			<xsl:call-template name="add-requiredproperties2json-schema"><xsl:with-param name="thedefinition" select="$thedefinition"/></xsl:call-template>
		<xsl:text>}</xsl:text>
	</xsl:template>

	<xsl:template name="add-property2json-schema">
		<xsl:param name="theproperty"/>
		<xsl:variable name="theattributeid" select="$theproperty/AttributeRef"/>
		<xsl:variable name="theattribute" select="//Attribute[@NodeID = $theattributeid]"/>

		<xsl:text>"</xsl:text><xsl:value-of select="$theattribute/TechnicalName"/><xsl:text>": {</xsl:text>
		<xsl:variable name="thedatatypeid" select="$theattribute/Datatype"/>
		<xsl:choose>
			<xsl:when test="$thedatatypeid!=''">
				<xsl:variable name="thedatatype" select="/Export/ResolvedRefs//Datatype[@NodeID=$thedatatypeid]"/>
				<xsl:choose>
					<xsl:when test="$thedatatype/BaseType='enum'">
			<xsl:text>"type": "string",</xsl:text>
			<xsl:text>"enum": [</xsl:text>
				<xsl:choose>
					<xsl:when test="$theattribute/FixedValue != ''">
						<xsl:variable name="theoptionid" select="$theattribute/FixedValue"/>
						"<xsl:value-of select="$thedatatype/Optionset/Option[@NodeID = $theoptionid]/Name"/>"
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each select="$thedatatype/Optionset/Option">"<xsl:value-of select="Code"/>"<xsl:if test="position() &lt; last()">,</xsl:if></xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>
					<xsl:text>],</xsl:text>
					</xsl:when>
					<xsl:otherwise>
			<xsl:text>"type": "</xsl:text><xsl:value-of select="$thedatatype/BaseType"/><xsl:text>",</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:variable name="thepattern" select="$thedatatype/Syntaxis"/>
				<xsl:if test="$thepattern!=''">
			<xsl:text>"pattern": "</xsl:text><xsl:value-of select="$thepattern"/><xsl:text>",</xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="$theattribute/AttributeType='Enum'">
			<xsl:text>"type": "string",</xsl:text>
			<xsl:text>"enum": [],</xsl:text>
					</xsl:when>
					<xsl:otherwise>
			<xsl:text>"type": "</xsl:text><xsl:value-of select="$theattribute/AttributeType"/><xsl:text>",</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
			<xsl:text>"description": "</xsl:text><xsl:value-of select="$theattribute/Definition"/><xsl:text>"</xsl:text>
			<xsl:text>}</xsl:text>
	</xsl:template>

	<xsl:template name="add-requiredproperties2json-schema">
		<xsl:param name="thedefinition"/>
		<xsl:text>"required": [</xsl:text>
		<xsl:for-each select="$thedefinition/PropertyGroup/Property[Required = 'Yes']">
			<xsl:variable name="theattributeid" select="AttributeRef"/>
			<xsl:variable name="theattribute" select="//Attribute[@NodeID = $theattributeid]"/>
			<xsl:text>"</xsl:text><xsl:value-of select="$theattribute/TechnicalName"/><xsl:text>"</xsl:text><xsl:if test="position() &lt; last()"><xsl:text>,</xsl:text></xsl:if>
		</xsl:for-each>
		<xsl:if test="$thedefinition/RuledObjectGroup/Required = 'Yes'">
			<xsl:if test="count($thedefinition/PropertyGroup/Property[Required = 'Yes']) &gt; 0"><xsl:text>,</xsl:text></xsl:if><xsl:text>"</xsl:text><xsl:value-of select="$thedefinition/RuledObjectGroup/PropertyName"/><xsl:text>"</xsl:text>
		</xsl:if><xsl:text>]</xsl:text>
	</xsl:template>
	
	<xsl:template name="add-arrays2json-schema">
		<xsl:param name="thedefinition"/>

		<xsl:for-each select="$thedefinition/RelatedObjectGroup/RelatedObject">
			<xsl:variable name="thedefinitionref" select="DefinitionRef"/>
			<xsl:variable name="thetargetdefinition" select="//Definition[@NodeID=$thedefinitionref]"/>
			<xsl:text>"</xsl:text><xsl:value-of select="PropertyName"/><xsl:text>": {</xsl:text>
				<xsl:text>"type": "array",</xsl:text>
				<xsl:text>"items": {"$ref": "#/definitions/</xsl:text><xsl:value-of select="$thetargetdefinition/Name"/><xsl:text>"}</xsl:text>
			<xsl:if test="MinItems!=''"><xsl:text>,"minItems": </xsl:text><xsl:value-of select="MinItems"/></xsl:if>
			<xsl:if test="MaxItems!=''"><xsl:text>,"maxItems": </xsl:text><xsl:value-of select="MaxItems"/></xsl:if>
			<xsl:if test="UniqueItems!=''"><xsl:text>,"uniqueItems": </xsl:text><xsl:value-of select="UniqueItems"/></xsl:if>
				<xsl:text>}</xsl:text><xsl:if test="position() &lt; last()"><xsl:text>,</xsl:text></xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="add-ruledobjects2json-schema">
		<xsl:param name="thedefinition"/>

		<xsl:variable name="theruledobjectcount" select="count($thedefinition/RuledObjectGroup/RuledObjects/DefinitionRef)"/>
		<xsl:if test="$theruledobjectcount &gt; 0">
			<xsl:text>"</xsl:text><xsl:value-of select="$thedefinition/RuledObjectGroup/PropertyName"/><xsl:text>": {"type": "object",</xsl:text>
			<xsl:text>"</xsl:text><xsl:value-of select="$thedefinition/RuledObjectGroup/RuleType"/><xsl:text>": [</xsl:text>
			<xsl:for-each select="$thedefinition/RuledObjectGroup/RuledObjects/DefinitionRef">
				<xsl:variable name="thedefinitionref" select="."/>
				<xsl:variable name="thetargetdefinition" select="//Definition[@NodeID=$thedefinitionref]"/>
				<xsl:text>{"$ref": "#/definitions/</xsl:text><xsl:value-of select="$thetargetdefinition/Name"/><xsl:text>"}</xsl:text><xsl:if test="position() &lt; last()"><xsl:text>,</xsl:text></xsl:if>
			</xsl:for-each><xsl:text>]}</xsl:text>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>