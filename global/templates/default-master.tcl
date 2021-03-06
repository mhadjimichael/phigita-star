# /www/master-default.tcl
#
# Set basic attributes and provide the logical defaults for variables that
# aren't provided by the slave page.
#
# Author: Kevin Scaldeferri (kevin@arsdigita.com)
# Creation Date: 14 Sept 2000
# $Id: default-master.tcl,v 1.1.1.1 2002/11/22 09:47:31 nkd Exp $
#

# fall back on defaults for title, signatory and header_stuff

if [template::util::is_nil title]     { set title        [ad_system_name]  }

if [template::util::is_nil signatory] { set signatory    [ad_system_owner] }
if ![info exists header_stuff]        { set header_stuff {}                }
if [template::util::is_nil context_bar]     { set context_bar {}  }
if [template::util::is_nil javascript]     { set javascript {}  }
if [template::util::is_nil return_url]     { 

    set return_url "[ns_urlencode [ad_conn url]]"
    if { ![string equal [ad_conn query] ""] } {
	append return_url "?[ad_conn query]"
    }
}

# Attributes

template::multirow create attribute key value

# Pull out the package_id of the subsite closest to our current node
set pkg_id [site_node_closest_ancestor_package "acs-subsite"]

template::multirow append \
    attribute bgcolor "ffffff"
template::multirow append \
    attribute text "000000"
template::multirow append \
    attribute leftmargin 15
template::multirow append \
    attribute topmargin 5
template::multirow append \
    attribute marginwidth 15
template::multirow append \
    attribute marginheight 5


if { ![template::util::is_nil onload] } {
    template::multirow append \
	attribute onload "$onload"
} elseif { ![template::util::is_nil focus] } {
    # Handle elements wohse name contains a dot
    regexp {^([^.]*)\.(.*)$} $focus match form_name element_name
    template::multirow append \
            attribute onLoad "javascript:document.forms\['${form_name}'\].elements\['${element_name}'\].focus()"
} else {
    set form_name ps
    set element_name q
    template::multirow append \
            attribute onLoad "javascript:document.forms\['${form_name}'\].elements\['${element_name}'\].focus()"
}


if { [info exists prefer_text_only_p]
     && $prefer_text_only_p == "f"
     && [ad_graphics_site_available_p] } {
  template::multirow append attribute background \
    [ad_parameter -package_id $pkg_id background dummy "/graphics/bg.gif"]
}



# Developer-support

if { [llength [namespace eval :: info procs ds_link]] == 1 } {
     set ds_link "[ds_link]"
} else {
    set ds_link ""
}



set user_id [ad_conn user_id]
