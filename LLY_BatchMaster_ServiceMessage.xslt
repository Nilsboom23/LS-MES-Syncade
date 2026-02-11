<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:BI="urn:EMR.BI.Framework.Lib" xmlns:cs="urn:cs" exclude-result-prefixes="msxsl BI cs" version="2.0">
  
  <!-- 
**  Copyright 2023. Emerson Process Management - All rights reserved
********************************************************************************
********************************************************************************
**  Purpose: Prepare a service message for the Batch Master Transaction to be 
**  send to the proper execution group  
********************************************************************************
********************************************************************************
**  Revision History:  
*****************  Version 0.0.0  ***************** 
**  User: JVergara   Date: 23-02-2024
**  Comment: Initial Release     
*****************  Version 1.0.0  ****************
**  User: SBabu   Date:  September 18 2024 
**  Comment: Code Review Complete                                      
*****************  Version 2.0  ****************
**  User: JVergara   Date:  February 04 2025
**  Comment: Released to Eli Lilly 
*********************************************************************************
-->
  
  <xsl:output method="xml" indent="yes" />
  
  <xsl:variable name="upperCase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
  <xsl:variable name="lowerCase" select="'abcdefghijklmnopqrstuvwxyz'" />

  <xsl:variable name="holdAttempts" select="'0'" />
  <xsl:variable name="holdSeconds" select="'5'" />
  <xsl:variable name="synchronousTask" select="'0'" />
  <xsl:variable name="configFile" select="'BI.DynamicWS.Config.xml'" />
  
  <xsl:variable name="isActiveTF" select="translate(//DoesLotExist/IM_Lot_DoesLotExist/InventoryLot/@ExistsTF, $upperCase, $lowerCase)" />

  
  <xsl:template match="@*|node()">
      <xsl:apply-templates select="//BatchMaster" />
  </xsl:template>
  
  <xsl:variable name="executionGroup">
	<xsl:choose>
		<xsl:when test="$isActiveTF = 'true'">
			<xsl:value-of select="'LLY_ERP_BatchMaster_Active'"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="'LLY_ERP_BatchMaster_Park'"/>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="syncGroupID">
	<xsl:value-of select="$executionGroup" />
  </xsl:variable>
  
  <xsl:template match="BatchMaster">
	<root>
		<ServiceMessage AssemblyPath="DMI.DynamicWS.dll" TypeName="ExecuteWS">
			<ServiceConfiguration HoldAttempts="{$holdAttempts}" HoldSeconds="{$holdSeconds}" SynchronousTask="{$synchronousTask}" SyncGroupID="{$syncGroupID}"/>
				<TaskMessage ConfigFile="{$configFile}">
					<Execute ExecutionGroupID="{$executionGroup}"/>	
						<xsl:copy-of select="." />				
				</TaskMessage>
		</ServiceMessage>
	</root>
  </xsl:template>
</xsl:stylesheet>

