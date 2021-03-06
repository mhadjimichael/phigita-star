ad_page_contract {
    Index page for the package manager.

    @param orderyby The parameter to order everything in the page by.
    @param owned_by Display packages owned by whom.
    @author Jon Salz (jsalz@arsdigita.com)
    @cvs-id $Id: index.tcl,v 1.1.1.1 2002/11/22 09:47:32 nkd Exp $
} {
    { orderby "package_key" }
    { owned_by "me" }
}

doc_body_append [apm_header]
set user_id [ad_get_user_id]
doc_body_append {
    [ <a href=layered-architecture>Layered Architecture</a> 
      - <a href=dependencies>Dependencies</a> ]<p>
}
# Determine the user's email address.  If its not registered, put in a default.  
set my_email [db_string email_by_user_id {
    select email  from parties where party_id = :user_id
} -default "me"]

set dimensional_list {
    {
        supertype "Package Type:" all {
	    { apm_application "Applications" { where "[db_map apm_application]" } }
	    { apm_service "Services" { where "t.package_type = 'apm_service'"} }
	    { all "All" {} }
	}
    }
    {

	owned_by "Owned by:" everyone {
	    { me "Me" {where "[db_map everyone]"} }
	    { everyone "Everyone" {where "1 = 1"} }
	}
    }
    {
	status "Status:" all {
	    {
		latest "Latest" {where "[db_map latest]" }
	    }
	    { all "All" {where "1 = 1"} }
	}
    }
}
# "latest" means that a version is installed or enabled, or there is no more latest version
# which is installed or enabled. Basically, any relevant package on the system.

set missing_text "<strong>No packages match criteria.</strong>"

doc_body_append "<center><table><tr><td>[ad_dimensional $dimensional_list]</td></tr></table></center>"

set table_def {
    { package_key "Key" "" "<td><a href=\"version-view?version_id=$version_id\">$package_key</a></td>" }
    { pretty_name "Name" "" "<td><a href=\"version-view?version_id=$version_id\">$pretty_name</a></td>" }
    { version_name "Ver." "" "" }
    { n_files "Files" "" {<td align=right>&nbsp;&nbsp;<a href=\"version-files?version_id=$version_id\">$n_files</a>&nbsp;</td>} }
    {
	status "Status" "" {<td align=center>&nbsp;&nbsp;[eval {
	    if { $installed_p == "t" } {
		if { $enabled_p == "t" } {
		    set status "Enabled"
		} else {
		    set status "Disabled"
		}
	    } elseif { $superseded_p } {
		set status "Superseded"
	    } else {
		set status "Uninstalled"
	    }
	    format $status
	}]&nbsp;&nbsp;</td>}
    }
    { maintained "Maintained" "" {<td align=center>[ad_decode $distribution_uri "" "Locally" "Externally"]</td>} }
    {
	action "" "" {<td bgcolor=white>&nbsp;&nbsp;[eval {
	    ns_log Debug "Status for $version_id: [apm_version_load_status $version_id]"
	    if { $installed_p == "t" && $enabled_p == "t" && \
		    [string equal [apm_version_load_status $version_id] "needs_reload"] } {
		format "<a href=\"version-reload?version_id=$version_id\">reload</a>"
	    } else {
		format ""
	    }
	}]&nbsp;&nbsp;</td>}
    }
}

doc_body_flush

set table [ad_table -Torderby $orderby -Tmissing_text $missing_text "apm_table" "" $table_def]

db_release_unused_handles

doc_body_append "<h3>Packages</h3><blockquote>$table</blockquote>
<ul>
<li><a href=\"package-add\">Create a new package.</a>
<li><a href=\"write-all-specs\">Write new specification files for all installed, locally generated packages</a>
<li><a href=\"package-load\">Load a new package from a URL or local directory.</a>
<li><a href=\"packages-install\">Install packages.</a>
</ul>
"

# Build the list of files we're watching.
set watch_files [nsv_array names apm_reload_watch]
if { [llength $watch_files] > 0 } {
    doc_body_append "<h3>Watches</h3><ul>\n"
    foreach file [lsort $watch_files] {
	if { [string compare $file "."] } {
	    doc_body_append "<li>$file (<a href=\"file-watch-cancel?watch_file=[ns_urlencode $file]\">stop watching this file</a>)\n"
	}
    }
    doc_body_append "</ul>\n"
}

doc_body_append "
<h3>Help</h3>

<blockquote>
A particular version of a package is <b>installed</b> if the files necessary to run it
are present in the filesystem.
It is <b>enabled</b> if it is scheduled to run at server startup
and deliverable by the request processor.

<p>If a Tcl library file (<tt>*-procs.tcl</tt>) or query file (<tt>*.xql</tt>) is being
<b>watched</b>, the request processor monitors it, reloading it into running interpreters
whenever it is changed. This is useful during development
(so you don't have to restart the server for your changes to take
effect). To watch a file, click its package key above, click <i>Manage file
information</i> on the next screen, and click <i>watch</i> next to
the file's name on the following screen.
</blockquote>

[ad_footer]
"

