<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
   
    <xsl:output indent="yes" method="xhtml" omit-xml-declaration="yes" doctype-system="about:legacy-compat"/>
    <!--JJF: This makes a variable for our collection folded, so we can call upon it later to
    capture all of the xml files and translate them into html pages.-->
    <xsl:variable name="morrowindColl" select="collection('morrowindColl/?select=*.xml')"/>
    
    
    
    
    <!--JJF: This is where all the variables are refrenced from the BarGraphElements.xsl in order for 
    the bookGenerator to go through all of the xml files and count -> create an svg bargraph
    for every one of the books.-->
    <xsl:variable name="X-Spacer" select="100"/>
    <xsl:variable name="Y-Stretcher" select="-5"/>
    <xsl:variable name="barWidth" select="30"/>
    <xsl:variable name="maxPersonCount" select="$morrowindColl//contents/count(.//person[@ref]) => max()"/>
    <xsl:variable name="maxLocationCount" select="$morrowindColl//contents/count(.//location[@ref]) => max()"/>
    <xsl:variable name="maxGroupCount" select="$morrowindColl//contents/count(.//group[@ref]) => max()"/>
    <xsl:variable name="maxItemCount" select="$morrowindColl//contents/count(.//item[@ref]) => max()"/>
    
    <!--jjf: we need to make a variable that gets the maximum of one of the variables and 
    for it to choose the maximum of all the variables.
    -->
    <xsl:variable name="YMax" select="($maxPersonCount, $maxLocationCount, $maxGroupCount, $maxItemCount) => max()"/>
    <!-- This is our root template establishing the structure of our HTML-output -->
    
    
    <!--JJF: Start of the html conversion-->
    <xsl:template match="/">
        <xsl:result-document href="../web/librarium/morrowindTables.html" method="xhtml"> 
        <!--ebb: xsl:result-document outputs a file with a file name. We'll use it again later to output each of the morrowind books in the collection. -->
         <html>
            <head>
                <title>Morrowind Book Information</title>
            <link rel="stylesheet" type="text/css" href="bookTable.css"/>
            <script type="text/javascript" src="showHideTables.js"></script>
                <!--JJF: This takes the link from two separate files in our repository
                and uses the code from them in order to style the html pages with CSS
                and to use the javascript files to show/hide the giant tables that
                are outputed onto the website.-->
            </head>
            <body>
                <div class="header">
                    <h2>Morrowind Librarium</h2>
                    
                </div>
                <!--JJF: This is where the menu pages are on the website, and gives the option to go
                through all of our pages-->
                <div class="nav"><ul>
                    <li><a class="active" href="../index.html">Home</a></li>
                    <li><a class="active" href="morrowindTables.html">The Librarium</a></li>
                    <li><a class="active" href="../About.html">About us</a></li>
                    <li><a class="active" href="../projectmethodology.html">Project Methodology</a></li>
                </ul></div>
                
                <section id="bookTables"><div class="header"><h1>Morrowind Book Tables</h1></div>
               <!--JJF: This section is using going through morrowindTables.html, and is using
               the flex-container command the tkae the tokenized names of the specific tables and
               place them within equally sized boxes that 4 containers on the same height.-->
                <ul class="flex-container">
                    <li class="flex-item"><a href="#items" class="button">Table of Items</a></li>
                    <li class="flex-item"><a href="#loc" class="button">Table of Locations</a></li>
                    <li class="flex-item"><a href="#group" class="button">Table of Groups</a></li>
                    <li class="flex-item"><a href="#persons" class="button">Table of Persons</a></li>
                </ul></section>
                
                <section><div class="header"><h1>Morrowind Book Information</h1></div>
                <ul class="flex-container">
                    <xsl:for-each select="$morrowindColl//Book">
                        <xsl:sort select="book_title"/>
                        <!--JJF: This sorts the table of contents in alphabetical order, so that it captures the book_title element 
                        within the morrowindColl directory.-->
                        <li class="flex-item"><a href="{tokenize(base-uri(), '/')[last()] ! substring-before(., '.')}.html" class="button"><xsl:apply-templates select="book_title"/></a></li>
                    </xsl:for-each>
                    
                </ul>
                    
                  
                </section>
              <section id="itemTable"><div class="header"><h2>Table of Items</h2></div> 
                  <button class="showhide" onclick="toggleitems()">Show/Hide Items</button>
                <!--JJF: This creates a button with the use of javascript to link directly down
                to the table of usable items within the librarium.-->
                  <table id="items">
                    <tr>
                        <!--JJF: Three columns are created, which use the code
                        below to help use xsl:for-each and the xsl:sort in order
                        to go alphabetically down the page, and to count how many instances of that
                        specific item are refrenced within entire collection. The last column
                        makes a link to the first instance of that specific ref attribute that
                        is in the table of contents.-->
                        <th>Items</th>
                        <th>Books with Counts</th>
                        <th>Link to First Mention in Each Book</th>
                    </tr>
                  <xsl:for-each select="$morrowindColl//item/@ref ! lower-case(.)! replace(.,'[-_]',' ') ! normalize-space() => distinct-values()">
                      <!--ebb: We have to use xsl:for-each instead of xsl:apply-templates to process this because distinct-values converts XML nodes into strings of text. -->          
                      <xsl:sort/>
                    <xsl:variable name="currentItem" as="xs:string" select="current()"/>
                  <tr>
                      <td><xsl:value-of select="current()!translate(.,'_',' ')"/></td>
                      
                      <td><ul>
                          <xsl:for-each select="$morrowindColl//Book[descendant::item/@ref ! lower-case(.)! replace(.,'[-_]',' ') ! normalize-space() = current()]">
                              
                              <xsl:sort select="count(current()/descendant::item[@ref ! lower-case(.) ! replace(.,'[-_]',' ') !  normalize-space() = $currentItem])" order="descending"/>  
                           <!--ebb: I repaired this sort() so it is working. Here I needed to sort on a count of item elements, not item/@ref attributes (there would always be just one @ref, so that's why the sort() didn't work before.) -->   
                              
                              <li><xsl:apply-templates select="book_title"/>, count: <xsl:value-of select="count(descendant::item[@ref ! lower-case(.)! replace(.,'[-_]',' ') ! normalize-space() = $currentItem])"/></li>              
                      </xsl:for-each>
                      </ul>
                      </td>
                      
                      
                      <td> <ul>
                          <xsl:for-each select="$morrowindColl//Book[descendant::item/@ref ! lower-case(.)! replace(.,'[-_]',' ') ! normalize-space()  = $currentItem]">
                              <li><a href="{tokenize(current()/base-uri(), '/')[last()] ! substring-before(., '.')}.html#{replace(descendant::item[@ref ! lower-case(.)! replace(.,'[-_]',' ') ! normalize-space() =$currentItem][1]/@ref ! lower-case(.)! replace(.,'[-_]',' ') ! normalize-space(), '[ '']', '')}">first mention</a></li>
                              
                          </xsl:for-each> 
                      </ul></td>
                      
                  </tr>
                  </xsl:for-each>
                    
                    
                </table></section>
             <hr/> <!-- horizontal rule line to separate sections-->
                <section><div class ="header"><h2>Table of locations</h2></div>
                    <button class="showhide" onclick="toggleloc()">Show/Hide Locations</button>
                <table id="loc">
                    <tr>
                        <th>Locations</th>
                        <th>Books with Counts</th>
                        <th>Link to First Mention in Each Book</th>
                    </tr>
                    <xsl:for-each select="distinct-values($morrowindColl//location/@ref ! lower-case(.)! replace(.,'[-_]',' ') ! normalize-space())">
                        <!--ebb: We have to use xsl:for-each instead of xsl:apply-templates to process this because distinct-values converts XML nodes into strings of text. -->
                        <xsl:sort/>
                        <!--ebb: This sorts the nodes in alphabetical order by the last name if there's space separator. -->
                        <xsl:variable name="currentLoc" as="xs:string" select="current()"/>
                        
                        <tr> <td><xsl:value-of select="current()!replace(.,'[-_]',' ')"/></td>
                            <td>
                                <ul><xsl:for-each select="$morrowindColl//Book[descendant::location/@ref! lower-case(.)! replace(.,'[-_]',' ') ! normalize-space() = current()]">
                                    <xsl:sort select="count(descendant::location[@ref! lower-case(.)! replace(.,'[-_]',' ') ! normalize-space() = $currentLoc])" order="descending"/>                 
                                    <li><xsl:apply-templates select="book_title"/>, count: <xsl:value-of select="count(descendant::location[@ref! lower-case(.)! replace(.,'[-_]',' ') ! normalize-space() = $currentLoc])"/></li>              
                                </xsl:for-each>
                                    
                                </ul>
                            </td>
                            <td>
                                <ul>
                                    <xsl:for-each select="$morrowindColl//Book[descendant::location/@ref! lower-case(.)! replace(.,'[-_]',' ') ! normalize-space()  = $currentLoc]">
                                        <li><a href="{tokenize(current()/base-uri(), '/')[last()] ! substring-before(., '.')}.html#{replace(descendant::location[@ref ! normalize-space() =$currentLoc][1]/@ref, '[ '']', '')}">first mention</a></li>
                                        
                                    </xsl:for-each> 
                                </ul>
                            </td>
                        </tr>
                    </xsl:for-each>   
                    
                    
                </table></section>
                
                <hr/> <!-- horizontal rule line to separate sections-->
                <section><div class="header"><h2>Table of Groups</h2></div>
                    <button class="showhide" onclick="togglegroup()">Show/Hide Groups</button>
             <table id="group">
                 <tr>
                     <th>Groups</th>
                     <th>Books with Counts</th>
                     <th>Link to First Mention in Each Book</th>
                 </tr>
                 <xsl:for-each select="distinct-values($morrowindColl//group/@ref! lower-case(.)! replace(.,'[-_]',' ') ! normalize-space() )">
                     <!--ebb: We have to use xsl:for-each instead of xsl:apply-templates to process this because distinct-values converts XML nodes into strings of text. -->
                     <xsl:sort select="tokenize(., ' ')[last()]"/>
                     <!--ebb: This sorts the nodes in alphabetical order  y the last name if there's space separator. -->
                     <xsl:variable name="currentGroup" as="xs:string" select="current()"/>
                     
                     <tr> <td><xsl:value-of select="current()!replace(.,'[-_]',' ')"/></td>
                         <td>
                             <ul><xsl:for-each select="$morrowindColl//Book[descendant::group/@ref! lower-case(.)! replace(.,'[-_]',' ') ! normalize-space() = current()]">
                                 <xsl:sort select="count(descendant::group[@ref! lower-case(.)! replace(.,'[-_]',' ') ! normalize-space()  = $currentGroup])" order="descending"/>                 
                                 <li><xsl:apply-templates select="book_title"/>, count: <xsl:value-of select="count(descendant::group[@ref! lower-case(.)! replace(.,'[-_]',' ') ! normalize-space()  = $currentGroup])"/></li>              
                             </xsl:for-each>
                                 
                             </ul>
                         </td>
                         <td>
                             <ul>
                                 <xsl:for-each select="$morrowindColl//Book[descendant::group[@ref! lower-case(.)! replace(.,'[-_]',' ') ! normalize-space()  = $currentGroup]]">
                                     <li><a href="{tokenize(current()/base-uri(), '/')[last()]! substring-before(., '.')}.html#{replace(descendant::group[@ref ! normalize-space()=$currentGroup][1]/@ref, '[ '']', '')}">first mention</a></li>
                                     
                                 </xsl:for-each> 
                             </ul>
                         </td>
                     </tr>
                 </xsl:for-each>    
              
                
             </table></section>
                <hr/> <!-- horizontal rule line to separate sections-->
                <section><div class="header"><h2>Table of Persons</h2></div>
                    <button class="showhide" onclick="togglepersons()">Show/Hide Persons</button>
                <table id="persons">
                    <tr>
                        <th>Persons</th>
                        <th>Books with Counts</th>
                        <th>Link to First Mention in Each Book</th>
                    </tr>
                    <xsl:for-each select="distinct-values($morrowindColl//person/@ref! lower-case(.)! replace(.,'[-_]',' ') ! normalize-space() )">
                        <!--ebb: We have to use xsl:for-each instead of xsl:apply-templates to process this because distinct-values converts XML nodes into strings of text. -->
                        <xsl:sort select="tokenize(., ' ')[last()]"/>
                        <!--ebb: This sorts the nodes in alphabetical order  y the last name if there's space separator. -->
                        <xsl:variable name="currentPerson" as="xs:string" select="current()"/>
                        
                        <tr> <td><xsl:value-of select="current()!replace(.,'[_-]',' ')"/></td>
                            <td>
                                <ul><xsl:for-each select="$morrowindColl//Book[descendant::person/@ref! lower-case(.)! replace(.,'[-_]',' ') ! normalize-space() = current()]">
                                    <xsl:sort select="count(descendant::person/@ref! lower-case(.)! replace(.,'[-_]',' ') ! normalize-space()  = $currentPerson)" order="descending"/>                 
                                    <li><xsl:apply-templates select="book_title"/>, count: <xsl:value-of select="count(descendant::person[@ref! lower-case(.)! replace(.,'[-_]',' ') ! normalize-space()  = $currentPerson])"/></li>              
                                </xsl:for-each>
                                    
                                </ul>
                            </td>
                            <td>
                                <ul>
                                    <xsl:for-each select="$morrowindColl//Book[descendant::person[@ref! lower-case(.)! replace(.,'[-_]',' ') ! normalize-space()  = $currentPerson]]">
                                        <li><a href="{tokenize(current()/base-uri(), '/')[last()]! substring-before(., '.')}.html#{replace(descendant::person[@ref ! normalize-space()=$currentPerson][1]/@ref, '[ '']', '')}">first mention</a></li>
                                        
                                    </xsl:for-each> 
                                </ul>
                            </td>
                        </tr>
                    </xsl:for-each>   
                </table></section>
            </body>
        </html>
        </xsl:result-document>
        
        <!--ebb: BELOW THIS, in a new xsl:for-each, we output each book as a separate document to save in the same file directory as the morrowindTables.html output file. -->
     
        <xsl:for-each select="$morrowindColl//Book">]
      <!--ebb: Set a variable to work out the new output filename for each book --><xsl:variable name="fileName" as="xs:string" select="tokenize(current()/base-uri(), '/')[last()] ! substring-before(., '.')"/>
 
            <xsl:result-document href="../web/librarium/{$fileName}.html" method="xhtml">
              <!--JJF: This is what goes through and translates all of the xml markup to html.
             The toekenized functions are used in order to create the filename based on the original
             title of the xml, and it just changes it to an .html extension.-->
                <html>
                  <head>
                      <title><xsl:apply-templates select="book_title"/></title>
                      <link rel="stylesheet" type="text/css" href="bookSpine.css"/>
                      <!--JJF: This is what determines the CSS for each html book page.-->
                   
                  </head>
                  <body>
                      
                      <div class="header">
                          <h2>Morrowind Librarium</h2>
                          
                      </div>
                      <div class="nav"><ul>
                          <!--JJF: This allows the buttons to be used again to navagate around 
                          the website and go to other pages.-->
                          <li><a class="active" href="../index.html">Home</a></li>
                          <li><a class="active" href="morrowindTables.html">The Libraruim</a></li>
                          <li><a class="active" href="../About.html">About us</a></li>
                          <li><a class="active" href="../projectmethodology.html">Project Methodology</a></li>
                      </ul></div>
                      
                      <div class="flex"><section id="content"><h1><xsl:apply-templates select="book_title"/></h1>
                       <h3><xsl:apply-templates select="writer"/></h3>
                      
                      <h4>Acquisitions</h4>
                      <ul id="acq"><xsl:apply-templates select="Acquisition/location"/></ul>
                      
                      <xsl:apply-templates select="contents"/></section>
                    <!--JJF: This code is from the BarGraphElements.xsl  it outputs below the books contents.-->
                          <section id="svg">
                        <xsl:variable name="locs" select="count(descendant::contents//location)"/>
                        <xsl:variable name="groups" select="count(descendant::contents//group)"/>
                        <xsl:variable name="peeps" select="count(descendant::contents//person)"/>
                        <xsl:variable name="items" select="count(descendant::contents//item)"/>
                        <xsl:if test="sum(($locs, $groups,$peeps,$items)) gt 0">                                                                                            
                                <svg viewBox="0 0 550 1000" preserveAspectRatio="xMinYMin meet">>
                                    <xsl:comment>maxPersonCount <xsl:value-of select="$maxPersonCount"/></xsl:comment>
                                    <xsl:comment>max of all the Y-values <xsl:value-of select="$YMax"/></xsl:comment>
                                    <xsl:comment>maxGroupCount <xsl:value-of select="$maxGroupCount"/></xsl:comment>
                                    <xsl:comment>maxLocationCount <xsl:value-of select="$maxLocationCount"/></xsl:comment>
                                    <xsl:comment>maxItemCount <xsl:value-of select="$maxItemCount"/></xsl:comment>
                                    <g transform="translate(80, 900)">
                                        <!--X axis --> 
                                        <line x1="0" y1="0" x2="{10 * $X-Spacer}" y2="0" stroke="indigo"/>
                                        <!--Y axis -->
                                        <line x1="0" y1="0" x2="0" y2="{$YMax * $Y-Stretcher}" stroke="indigo"/>
                                        
                                        
                                        <!--            <xsl:variable name="YPos" select="count($maxElementCount) * $Y-Stretcher"/>-->
                                        <!--JJF: This needs to be finding another y-element for something to be max, so it needs to 
                    count person,group,item, and location and attempt to take the max-->
                                        <xsl:variable name="personCount" select="count(.//person[@ref])"/>
                                        <xsl:variable name="itemCount" select="count(.//item[@ref])"/>
                                        <xsl:variable name="locationCount" select="count(.//location[@ref])"/>
                                        <xsl:variable name="groupCount" select="count(.//group[@ref])"/>
                                    
                                        <xsl:variable name="barValues" select="tokenize('person group item location', ' ')"/>    
                                        
                                        
                                        <xsl:for-each select="$barValues">
                                            <xsl:variable name="XPos" select="position() * $X-Spacer"/>
                                            <xsl:if test="position() = 1"><line x1="{$XPos}" y1="0" x2="{$XPos}" y2="{$maxPersonCount * $Y-Stretcher}" stroke="WhiteSmoke" stroke-width="50"/>
                                                <line x1="{$XPos}" y1="0" x2="{$XPos}" y2="{$personCount * $Y-Stretcher}" stroke="pink" stroke-width="50"/>
                                                <text x="{$XPos}"  y="30" style="writing-mode: tb; glyph-orientation-vertical: 90;"> People </text>
                                            </xsl:if>
                                            <xsl:if test="position() = 2"><line x1="{$XPos}" y1="0" x2="{$XPos}" y2="{$maxGroupCount * $Y-Stretcher}" stroke="WhiteSmoke" stroke-width="50"/>
                                                <line x1="{$XPos}" y1="0" x2="{$XPos}" y2="{$groupCount * $Y-Stretcher}" stroke="blue" stroke-width="50"/>
                                                <text x="{$XPos}"  y="30" style="writing-mode: tb; glyph-orientation-vertical: 90;"> Groups </text>
                                            </xsl:if>
                                            <xsl:if test="position() = 3"><line x1="{$XPos}" y1="0" x2="{$XPos}" y2="{$maxItemCount * $Y-Stretcher}" stroke="WhiteSmoke" stroke-width="50"/>
                                                <line x1="{$XPos}" y1="0" x2="{$XPos}" y2="{$itemCount * $Y-Stretcher}" stroke="yellow" stroke-width="50"/>
                                                <text x="{$XPos}"  y="30" style="writing-mode: tb; glyph-orientation-vertical: 90;"> Items </text>
                                            </xsl:if>
                                            
                                            <xsl:if test="position() = 4">
                                                
                                                <line x1="{$XPos}" y1="0" x2="{$XPos}" y2="{$maxLocationCount * $Y-Stretcher}" stroke="WhiteSmoke" stroke-width="50"/>
                                                <line x1="{$XPos}" y1="0" x2="{$XPos}" y2="{$locationCount * $Y-Stretcher}" stroke="orange" stroke-width="50"/>
                                                <text x="{$XPos}"  y="30" style="writing-mode: tb; glyph-orientation-vertical: 90;"> Locations </text>
                                            </xsl:if>                                                                                                
                                        </xsl:for-each>
                                        
                                        <text x="-20" y="-200" style="writing-mode: tb; glyph-orientation-vertical: 90;"> Quantity of ID used</text>
                                        <!--Y-Axis title-->
                               
                                        <text x="125"  y="-800">Count of Morrowind References</text>
                                        <!--Graph title-->
                                        
                                        
                                    </g>
                                </svg>
                            </xsl:if>
                       
                    </section> </div>
                  </body>
              </html>
          </xsl:result-document>
      </xsl:for-each>   
    </xsl:template>
    
    <xsl:template match="Acquisition/location">
        <li><xsl:apply-templates/>: Visitable? <xsl:apply-templates select="@visitable"/></li>
    </xsl:template>   
    
    <xsl:template match="p">
        <p><xsl:apply-templates/></p>
    </xsl:template>
    
    <!--JJF: Everything below this just makes sure that if the count of a item,location,group, or person is listed as 0
    then it will not display at all on the tables.-->
    
    <xsl:template match="item">
        <xsl:choose>
            <xsl:when test="count(preceding::item) = 0">
                <span class="{name()}" id="{replace(@ref, '[ '']', '') ! lower-case(.)! replace(.,'[-_]',' ') ! normalize-space()}"><xsl:apply-templates/></span>
            </xsl:when>
            <xsl:otherwise>
                <span class="{name()}"><xsl:apply-templates/></span>
            </xsl:otherwise>
        </xsl:choose>    
    </xsl:template>
    
    <xsl:template match="location">
        <xsl:choose>
            <xsl:when test="count(preceding::location) = 0">
                <span class="{name()}" id="{replace(@ref, '[ '']', '')}"><xsl:apply-templates/></span>
            </xsl:when>
            <xsl:otherwise>
                <span class="{name()}"><xsl:apply-templates/></span>
            </xsl:otherwise>
        </xsl:choose>    
    </xsl:template>
    
    <xsl:template match="group">
        <xsl:choose>
            <xsl:when test="count(preceding::group) = 0">
                <span class="{name()}" id="{replace(@ref, '[ '']', '')}"><xsl:apply-templates/></span>
            </xsl:when>
            <xsl:otherwise>
                <span class="{name()}"><xsl:apply-templates/></span>
            </xsl:otherwise>
        </xsl:choose>    
    </xsl:template>
    
    <xsl:template match="person">
        <xsl:choose>
            <xsl:when test="count(preceding::person) = 0">
                <span class="{name()}" id="{replace(@ref, '[ '']', '')}"><xsl:apply-templates/></span>
            </xsl:when>
            <xsl:otherwise>
                <span class="{name()}"><xsl:apply-templates/></span>
            </xsl:otherwise>
        </xsl:choose>    
    </xsl:template>
  
</xsl:stylesheet>
