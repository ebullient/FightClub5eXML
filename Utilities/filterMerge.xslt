<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exsl="http://exslt.org/common"
    xmlns:set="http://exslt.org/sets"
    xmlns:str="http://exslt.org/strings">
    <xsl:output method="xml" indent="yes" />

    <!-- Merge the compendiums together -->
    <xsl:template match="collection">
        <!-- Store compendium in an intermediate format (firstStage) -->
        <xsl:variable name="altered">
            <xsl:apply-templates mode="firstStage" select="document(doc/@href)" />
        </xsl:variable>

        <!-- Second stage works from the output of the first stage (held in a node-set) -->
        <compendium version="5" auto_indent="NO">
            <xsl:call-template name="items-extendable">
                <xsl:with-param name="items" select="exsl:node-set($altered)/compendium/item" />
            </xsl:call-template>

            <xsl:apply-templates mode="secondStage" select="exsl:node-set($altered)/compendium/race"/>

            <xsl:call-template name="class-extendable">
                <xsl:with-param name="classes" select="exsl:node-set($altered)/compendium/class" />
            </xsl:call-template>

            <xsl:apply-templates mode="secondStage" select="exsl:node-set($altered)/compendium/feat"/>
            <xsl:apply-templates mode="secondStage" select="exsl:node-set($altered)/compendium/background"/>

            <xsl:call-template name="spells-extendable">
                <xsl:with-param name="spells" select="exsl:node-set($altered)/compendium/spell" />
            </xsl:call-template>

            <xsl:apply-templates mode="secondStage" select="exsl:node-set($altered)/compendium/monster"/>
        </compendium>
    </xsl:template>

    <!-- Formatting / Name changes (firstStage) -->

    <xsl:template mode="firstStage" match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates mode="firstStage" select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- Convert spell class comma-separated list to <c></c> elements -->
    <xsl:template mode="firstStage" match="compendium/spell/classes">
        <classes>
            <xsl:for-each select="str:tokenize(str:replace(., ', ', ','), ',')">
                <spellClass>
                    <xsl:value-of select="." />
                </spellClass>
            </xsl:for-each>
        </classes>
    </xsl:template>

    <!-- Add sorting keys to dice rolls -->
    <xsl:template mode="firstStage" match="roll">
        <xsl:variable name="extra" select="str:split(., '+')" />
        <xsl:variable name="bits" select="str:split($extra[1], 'd')" />
        <xsl:copy>
            <xsl:copy-of select="@*" />
            <xsl:attribute name="num"><xsl:value-of select="$bits[1]" /></xsl:attribute>
            <xsl:attribute name="die"><xsl:value-of select="$bits[2]" /></xsl:attribute>
            <xsl:copy-of select="node()" />
        </xsl:copy>
    </xsl:template>

    <!-- Merge and extend items (second stage)  -->

    <xsl:template name="items-extendable">
        <xsl:param name="items" />
        <xsl:for-each select="$items">
            <xsl:choose>
                <!-- Check if there's a duplicate -->
                <xsl:when test="count($items[name = current()/name]) &gt; 1">
                    <!-- Use the original class that includes the "type" element -->
                    <!-- Important: Duplicate items should only specify additional attributes like rolls -->
                    <xsl:if test="type">
                        <xsl:variable name="modifier_list">
                            <xsl:for-each select="$items[name = current()/name]/modifier">
                                <xsl:sort select="." order="ascending"/>
                                <xsl:copy-of select='.'/>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="item_roll_list">
                            <xsl:for-each select="$items[name = current()/name]/roll">
                                <xsl:sort select="." order="ascending"/>
                                <xsl:copy-of select='.'/>
                            </xsl:for-each>
                        </xsl:variable>
                        <item>
                            <!-- <count_dupes><xsl:value-of select="count($items[name = current()/name])"/></count_dupes> -->
                            <xsl:apply-templates mode="secondStage" select="name" />
                            <xsl:apply-templates mode="secondStage" select="type" />
                            <xsl:apply-templates mode="secondStage" select="magic" />
                            <xsl:apply-templates mode="secondStage" select="detail" />
                            <xsl:apply-templates mode="secondStage" select="weight" />
                            <xsl:apply-templates mode="secondStage" select="text" />
                            <xsl:copy-of select="set:distinct(exsl:node-set($item_roll_list)/roll)" />
                            <xsl:apply-templates mode="secondStage" select="value" />
                            <xsl:copy-of select="set:distinct(exsl:node-set($modifier_list)/modifier)" />
                            <xsl:apply-templates mode="secondStage" select="ac" />
                            <xsl:apply-templates mode="secondStage" select="strength" />
                            <xsl:apply-templates mode="secondStage" select="stealth" />
                            <xsl:apply-templates mode="secondStage" select="dmg1" />
                            <xsl:apply-templates mode="secondStage" select="dmg2" />
                            <xsl:apply-templates mode="secondStage" select="dmgType" />
                            <xsl:apply-templates mode="secondStage" select="property" />
                            <xsl:apply-templates mode="secondStage" select="range" />
                        </item>
                    </xsl:if>
                </xsl:when>
                <!-- If no duplicate, copy in the whole item -->
                <xsl:otherwise>
                    <item>
                        <xsl:apply-templates mode="secondStage" select="name" />
                        <xsl:apply-templates mode="secondStage" select="type" />
                        <xsl:apply-templates mode="secondStage" select="magic" />
                        <xsl:apply-templates mode="secondStage" select="detail" />
                        <xsl:apply-templates mode="secondStage" select="weight" />
                        <xsl:apply-templates mode="secondStage" select="text" />
                        <xsl:apply-templates mode="secondStage" select="roll" />
                        <xsl:apply-templates mode="secondStage" select="value" />
                        <xsl:apply-templates mode="secondStage" select="modifier"/>
                        <xsl:apply-templates mode="secondStage" select="ac" />
                        <xsl:apply-templates mode="secondStage" select="strength" />
                        <xsl:apply-templates mode="secondStage" select="stealth" />
                        <xsl:apply-templates mode="secondStage" select="dmg1" />
                        <xsl:apply-templates mode="secondStage" select="dmg2" />
                        <xsl:apply-templates mode="secondStage" select="dmgType" />
                        <xsl:apply-templates mode="secondStage" select="property" />
                        <xsl:apply-templates mode="secondStage" select="range" />
                    </item>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <!-- Merge and extend Classes (second stage)  -->

    <xsl:template name="class-extendable">
        <xsl:param name="classes" />
        <xsl:for-each select="$classes">
            <xsl:choose>
                <!-- Check if there's a duplicate -->
                <xsl:when test="count($classes[name = current()/name]) &gt; 1">
                    <!-- Use the original class that includes the "hd" element -->
                    <!-- Important: Subclasses should only contain "name" and "autolevel" elements -->
                    <xsl:if test="hd">
                        <class>
                            <xsl:apply-templates mode="secondStage" select="name" />
                            <xsl:apply-templates mode="secondStage" select="hd" />
                            <xsl:apply-templates mode="secondStage" select="proficiency" />
                            <xsl:apply-templates mode="secondStage" select="spellAbility" />
                            <xsl:apply-templates mode="secondStage" select="numSkills" />
                            <xsl:apply-templates mode="secondStage" select="armor" />
                            <xsl:apply-templates mode="secondStage" select="weapons" />
                            <xsl:apply-templates mode="secondStage" select="tools" />
                            <xsl:apply-templates mode="secondStage" select="wealth" />

                            <xsl:for-each select="$classes[name = current()/name]">
                                <xsl:apply-templates mode="secondStage" select="autolevel"/>
                            </xsl:for-each>
                        </class>
                    </xsl:if>
                </xsl:when>
                <!-- If no duplicate, copy in the whole class -->
                <xsl:otherwise>
                    <xsl:apply-templates mode="secondStage" select="." />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <!-- Merge and extend spells (second stage) -->

    <xsl:template name="spells-extendable">
        <xsl:param name="spells" />
        <xsl:for-each select="$spells">
            <xsl:choose>
                <!-- Check if there's a duplicate -->
                <xsl:when test="count($spells[name = current()/name]) &gt; 1">
                    <!-- Use the original spell that includes the "level" element -->
                    <!-- Important: Duplicate spells should only contain "name", and
                         "classes" and/or "roll" elements -->
                    <xsl:if test="level">
                        <spell>
                            <xsl:apply-templates mode="secondStage" select="name" />
                            <xsl:apply-templates mode="secondStage" select="level" />
                            <xsl:apply-templates mode="secondStage" select="school" />
                            <xsl:apply-templates mode="secondStage" select="ritual" />
                            <xsl:apply-templates mode="secondStage" select="time" />
                            <xsl:apply-templates mode="secondStage" select="range" />
                            <xsl:apply-templates mode="secondStage" select="components" />
                            <xsl:apply-templates mode="secondStage" select="duration" />

                            <!-- Extend the spell definition with classes from other lists-->
                            <classes>
                                <xsl:variable name="sorted_class_list">
                                    <xsl:for-each select="$spells[name = current()/name]/classes/spellClass">
                                        <xsl:sort select="." order="ascending"/>
                                        <xsl:copy-of select='.'/>
                                    </xsl:for-each>
                                </xsl:variable>
                                <xsl:apply-templates mode="secondStage" select="set:distinct(exsl:node-set($sorted_class_list)/spellClass)"/>
                            </classes>

                            <xsl:apply-templates mode="secondStage" select="source" />
                            <xsl:apply-templates mode="secondStage" select="text" />

                            <!-- Extend the spell definition with rolls from other lists-->
                            <xsl:variable name="spell_roll_list">
                                <xsl:for-each select="$spells[name = current()/name]/roll">
                                    <xsl:sort select="@num" order="ascending" data-type="number"/>
                                    <xsl:sort select="@die" order="ascending" data-type="number"/>
                                    <xsl:copy-of select='.'/>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:apply-templates mode="secondStage" select="set:distinct(exsl:node-set($spell_roll_list)/roll)" />
                        </spell>
                    </xsl:if>
                </xsl:when>
                <!-- If no duplicate, copy in the whole spell -->
                <xsl:otherwise>
                    <spell>
                        <xsl:apply-templates mode="secondStage" select="name" />
                        <xsl:apply-templates mode="secondStage" select="level" />
                        <xsl:apply-templates mode="secondStage" select="school" />
                        <xsl:apply-templates mode="secondStage" select="ritual" />
                        <xsl:apply-templates mode="secondStage" select="time" />
                        <xsl:apply-templates mode="secondStage" select="range" />
                        <xsl:apply-templates mode="secondStage" select="components" />
                        <xsl:apply-templates mode="secondStage" select="duration" />
                        <xsl:apply-templates mode="secondStage" select="classes" />
                        <xsl:apply-templates mode="secondStage" select="source" />
                        <xsl:apply-templates mode="secondStage" select="text" />
                        <!-- Sort the rolls, no duplicates-->
                        <xsl:variable name="spell_roll_list">
                            <xsl:for-each select="roll">
                                <xsl:sort select="@num" order="ascending" data-type="number"/>
                                <xsl:sort select="@die" order="ascending" data-type="number"/>
                                <xsl:copy-of select='.'/>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:apply-templates mode="secondStage" select="set:distinct(exsl:node-set($spell_roll_list)/roll)" />
                    </spell>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <!-- General copy elements (second stage) -->

    <xsl:template mode="secondStage" match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates mode="secondStage" select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template mode="secondStage" match="spellClass">
        <xsl:if test="position() > 1">, </xsl:if>
        <xsl:value-of select="." />
    </xsl:template>

    <xsl:template mode="secondStage" match="roll">
        <!-- Drop sorting attributes -->
        <xsl:copy>
            <xsl:apply-templates mode="secondStage" select="node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:transform>
