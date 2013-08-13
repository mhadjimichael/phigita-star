source ../../naviserver_compat/tcl/module-naviserver_compat.tcl

::xo::lib::require curl
::xo::lib::require tdom_procs
::xo::lib::require util_procs
::xo::lib::require htmltidy

package require uri
package require sha1

set feeds [dict create \
	       philenews {
		   url http://www.philenews.com/
		   include_re {/el-gr/.+/[0-9]+/[0-9]+/}
	       } \
	       sigmalive {
		   url http://www.sigmalive.com/
		   include_re {/[0-9]+}
		   exclude_re {/inbusiness/}
		   keep_title_from_feed_p 0
		   xpath_article_title {//h2[@class="cat_article_title"]/a}
		   xpath_article_body {//div[@id="article_content"]}
		   xpath_article_image {
		       {values(//div[@id="article_content"]/img/@src)}
		       {values(//div[@id="article_content"]//img[@class="pyro-image"]/@src)}
		   }
		   xpath_article_author {returnstring(//div[@class="article_meta"]/span[@class="meta_author"]/a/text())}
		   xpath_article_date {returnstring(//div[@class="article_meta"]/span[@class="meta_date"]/strong/text())}
		   xpath_article_cleanup {
		       {//div[@class="soSialIcons"]}
		       {//div[@class="article_meta"]}
		   }
	       } \
	       inbusiness {
		   url http://www.sigmalive.com/inbusiness/
		   include_re {/inbusiness/.*/[0-9]+}
		   keep_title_from_feed_p 0
		   xpath_article_title {//div[@id="articleContainer"]/h1}
		   xpath_article_body {//div[@id="articleContainer"]/div[@class="content"]/div[1]}
		   xpath_article_image {
		       {values(//div[@class="articleImg"]/div[@class="img"]/img/@src)}
		   }
		   xpath_article_date {substring-after(//div[@id="articleContainer"]/h4/text(),"| ")}
		   xpath_article_cleanup {
		       {//div[@id="articleContainer"]/h4}
		   }
	       } \
	       paideia-news {
		   url http://www.paideia-news.com/
		   include_re {id=[0-9]+&hid=[0-9]+}
		   htmltidy_article_p 1
		   xpath_article_title {//div[@class="main_resource_title_single"]}
		   xpath_article_author {returnstring(//div[@class="main_resource_summ2"]/p/strong/span)}
		   xpath_article_body {//div[@class="main_resource_summ2"]}
		   xpath_article_image {values(//div[@class="main_resource_img_single"]/img/@src)}
		   xpath_article_cleanup {
		       {//div[@class="main_resource_summ2"]/p/strong/span}
		   }
	       } \
	       haravgi {
		   url http://www.haravgi.com.cy/rss/rss.php
		   feed_type "rss"
		   include_re {site-article-[0-9]+-gr.php}
	       } \
	       ant1iwo {
		   url http://www.ant1iwo.com/
		   include_re {/[0-9]{4}/[0-9]{2}/[0-9]{2}/}
		   xpath_article_title {//div[@id="il_title"]/h1}
		   xpath_article_body {//div[@id="il_text"]}
		   xpath_article_date {substring-after(//div[@id="il_pub_date"]/div[@class="pubdate"]/text(),": ")}
	       }]



#array set feed [dict get $feeds philenews]
#array set feed [dict get $feeds sigmalive]
#array set feed [dict get $feeds paideia-news]
#array set feed [dict get $feeds inbusiness]
#array set feed [dict get $feeds haravgi]
array set feed [dict get $feeds ant1iwo]

proc compare_href_attr {n1 n2} {
    return [string compare [${n1} @href ""] [${n2} @href ""]]
}

proc filter_title {stoptitlesVar title} {
    upvar $stoptitlesVar stoptitles

    if { [info exists stoptitles(${title})] } {
	return ""
    } else {
	return ${title}
    }
}

#TODO: trim non-greek and non-latin letters from beginning and end of title
proc trim_title {title} {
    #set re {^[^0-9a-z\u0370-\03FF]*}
    #return [regexp -inline -- ${re} ${title}]
    return [string trim ${title} " -\t\n\r"]
}


proc get_title {stoptitlesVar node} {
    upvar $stoptitlesVar stoptitles

    set nodeType [${node} nodeType]

    if { ${nodeType} eq {ELEMENT_NODE} } {

	# returns all text node children of that current node combined
	set title [filter_title stoptitles [trim_title [${node} text]]]

	if { ${title} ne {} } {
	    return ${title}
	}

	foreach child [${node} childNodes] {
	    set title [get_title stoptitles ${child}]
	    if { ${title} ne {} } {
		return ${title}
	    }
	}

    } elseif { ${nodeType} eq {TEXT_NODE} } {

	return [filter_title stoptitles [trim_title [${node} nodeValue]]]

    }

}

proc ::util::domain_from_url {url} {

    set index [string first {:} ${url}]
    if { ${index} == -1 } {
	return
    }

    set scheme [string range ${url} 0 ${index}]
    if { ${scheme} ne {http:} && ${scheme} ne {https:} } {
	return
    }

    array set uri_parts [::uri::split ${url}]
    return $uri_parts(host)
}


proc get_feed_items {resultVar feedVar {stoptitlesVar ""}} {
    upvar $resultVar result
    upvar $feedVar feed
    upvar $stoptitlesVar stoptitles

    set url         $feed(url)
    set include_re  $feed(include_re)
    set exclude_re  [::util::var::get_value_if feed(exclude_re) ""]

    if { [info exists feed(domain)] } {
	set domain $feed(domain)
    } else {
	set domain [::util::domain_from_url ${url}]
    }

    set xpath_feed_item {//a[@href]}
    if { [info exists feed(xpath_feed_item)] } {
	set xpath_feed_item $feed(xpath_feed_item)
    }

    set encoding {utf-8}
    if { [info exists feed(encoding)] } {
	set encoding $feed(encoding)
    }

    ::xo::http::fetch html $url
    
    set html [encoding convertfrom ${encoding} ${html}]

    set doc [dom parse -html ${html}]
    set nodes [$doc selectNodes ${xpath_feed_item}]

    set nodes2 [list]
    array set title_for_href [list]
    foreach node $nodes {

	# turn relative urls into absolute urls and canonicalize	
	set href [::uri::canonicalize [::uri::resolve ${url} [${node} @href ""]]]

	# drop urls from other domains
	if { [::util::domain_from_url ${href}] ne ${domain} } {
	    continue
	}

	# drop links that do not match regular expression
	if { ![regexp -- ${include_re} ${href}] || ( ${exclude_re} ne {} && [regexp -- ${exclude_re} ${href}] ) } {
	    continue
	}

	${node} setAttribute href ${href}
	
	set title [get_title stoptitles ${node}]

	if { ![info exists title_for_href(${href})] } {
	    # coalesce title candidate values
	    set title_for_href(${href}) ${title}
	} else {
	    set title_for_href(${href}) [lsearch -inline -not [list ${title} $title_for_href(${href})] {}]
	}


	lappend nodes2 ${node}

    }

    # remove duplicates
    set nodes3 [lsort -unique -command compare_href_attr ${nodes2}]

    array set result [list links "" titles ""]
    foreach node ${nodes3} {

	set href [${node} @href]
	lappend result(links)  ${href}
	lappend result(titles) $title_for_href(${href})

    }

    # cleanup
    $doc delete
}


proc fetch_item {link title_in_feed feedVar itemVar} {

    upvar $feedVar feed
    upvar $itemVar item

    set encoding [::util::var::get_value_if feed(encoding) utf-8]

    set htmltidy_article_p [::util::var::get_value_if \
				feed(htmltidy_article_p) \
				0]

    set keep_title_from_feed_p [::util::var::get_value_if \
				    feed(keep_title_from_feed_p) \
				    0]

    # {//meta[@property="og:title"]}
    set xpath_article_title [::util::var::get_value_if \
				 feed(xpath_article_title) \
				 {//title}]

    set xpath_article_body [::util::var::get_value_if \
				feed(xpath_article_body) \
				{}]

    set xpath_article_cleanup [::util::var::get_value_if \
				   feed(xpath_article_cleanup) \
				   {}]

    set xpath_article_author [::util::var::get_value_if \
				  feed(xpath_article_author) \
				  {}]

    set xpath_article_image [::util::var::get_value_if \
				 feed(xpath_article_image) \
				 {values(//meta[@property="og:image"]/@content)}]

    set xpath_article_description [::util::var::get_value_if \
				       feed(xpath_article_description) \
				       {values(//meta[@property="og:description"]/@content)}]


    set xpath_article_date [::util::var::get_value_if \
				feed(xpath_article_date) \
				{}]


    set html ""
    ::xo::http::fetch html ${link}

    set html [encoding convertfrom ${encoding} ${html}]

    if { ${htmltidy_article_p} } {
	set html [::htmltidy::tidy ${html}]
    }

    set doc [dom parse -html ${html}]

    set title_node [${doc} selectNodes ${xpath_article_title}]
    set title_in_article [string trim [${title_node} text]]
    ${title_node} delete

    set author_in_article ""
    if { ${xpath_article_author} ne {} } {
	set author_in_article [${doc} selectNodes ${xpath_article_author}]
    }

    if { ${keep_title_from_feed_p} || ${title_in_article} eq {} } {
	set article_title ${title_in_feed}
    } else {
	set article_title ${title_in_article}
    }

    set article_image [list]
    if { ${xpath_article_image} ne {} } {
	foreach image_xpath ${xpath_article_image} {
	    foreach image_url [${doc} selectNodes ${image_xpath}] {
		lappend article_image [::uri::canonicalize \
					   [::uri::resolve \
						$link \
						$image_url]]
	    }
	}
    }

    set article_date ""
    if { ${xpath_article_date} ne {} } {
	set article_date [${doc} selectNodes ${xpath_article_date}]
    }

    set article_description ""
    if { ${xpath_article_description} ne {} } {
	set article_description [${doc} selectNodes ${xpath_article_description}]
    }

    # remove script nodes
    foreach cleanup_node [${doc} selectNodes {//script}] {
	$cleanup_node delete
    }

    foreach cleanup_xpath ${xpath_article_cleanup} {
	foreach cleanup_node [${doc} selectNodes ${cleanup_xpath}] {
	    ${cleanup_node} delete
	}
    }

    set article_body ""
    if { ${xpath_article_body} ne {} } {
	set article_body_node [${doc} selectNodes ${xpath_article_body}]
	set article_body [${article_body_node} asHTML]
	regsub -all -- {<[^>]*>} ${article_body} "\n" article_body
	regsub -all -- {\n{3,}} ${article_body} "\n\n" article_body

	#set article_body [${article_body_node} asText]
	#set article_body [${doc} selectNodes returnstring(${xpath_article_body})]
    }

    array set item [list \
			title $article_title \
			description $article_description \
			author $author_in_article \
			image $article_image \
			date $article_date \
			content $article_body]

    puts "Title: $article_title"
    puts "Description: $article_description"
    puts "Author: $author_in_article"
    puts "Image: $article_image"
    puts "Date: $article_date"


    # TODO: xpathfunc returntext (that returns structured text from html)
    puts "Content: [string range $article_body 0 200]"
    # puts "Content: $article_body"

    $doc delete
}

proc get_item_dir {link} {

    array set uri_parts [::uri::split ${link}]

    set reversehost [join [lreverse [split $uri_parts(host) {.}]] {.}]
    set urlsha1 [::sha1::sha1 -hex ${link}]

    set dir /web/data/crawldb/${reversehost}/${urlsha1}/

    return ${dir}

}

proc exists_item {link feedVar} {
    upvar $feedVar feed

    return [file isdirectory [get_item_dir ${link}]]

}

proc write_item {link feedVar itemVar} {
    upvar $feedVar feed
    upvar $itemVar item

    set dir [get_item_dir ${link}]

    if { ![file isdirectory ${dir}] } {
	file mkdir ${dir}
    }

    set data [array get item]
    set datasha1 [::sha1::sha1 -hex ${data}]
    set filename ${dir}/${datasha1}

    # note that it overwrites the file if it already exists with the same content
    set fp [open ${filename} "w"]
    puts $fp ${data}
    close ${fp}

}

array set stoptitles [list]
foreach title [split [::util::readfile stoptitles.txt] "\n"] {
    set stoptitles(${title}) 1
}

set feed_type [::util::var::get_value_if feed(type) ""] 
if { ${feed_type} eq {rss} } {
    set feed(xpath_feed_item) //item
}

get_feed_items result feed stoptitles

foreach link $result(links) title_in_feed $result(titles) {
    puts ${title_in_feed}
    puts ${link}
    puts "---"

    #continue

    if { ![exists_item ${link} feed] } {
	fetch_item ${link} ${title_in_feed} feed item
	write_item ${link} feed item
    }

}
