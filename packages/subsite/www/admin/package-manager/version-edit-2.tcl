ad_page_contract {
    Edit a package version
    @author Bryan Quinn (bquinn@arsdigita.com)
    @date 17 April 2000
    @cvs-id $Id: version-edit-2.tcl,v 1.1.1.1 2002/11/22 09:47:32 nkd Exp $

} {
    version_id:naturalnum,notnull
    version_name
    version_uri
    summary
    description
    {description_format ""}
    { owner_name:multiple}
    { owner_uri:multiple}
    vendor
    vendor_uri
    {release_date ""}
    { upgrade_p 0 }
} -validate {
    version_uri_unique -requires {version_uri} {
	if { [db_string apm_version_uri_unique_ck {
	    select decode(count(*), 0, 0, 1) from apm_package_versions 
	    where version_uri = :version_uri
	} -default 0] } {
	    ad_complain "A version with the URL $version_uri already exists."
	}
    }

    version_name_ck -requires {version_name} {	
	if {![regexp {^[0-9]+((\.[0-9]+)+((d|a|b|)[0-9]?)?)$} $version_name match]} {
	    ad_complain
	} 
    }
    version_changed_ck -requires {version_id version_name version_uri} {
	# The user has to update the URL if he changes the name.
	db_1row old_version_name "
	    select version_name old_version_name, version_uri old_version_uri 
	    from apm_package_versions
	    where version_id = $version_id
	"
	set version_changed_p [string compare $version_name $old_version_name]
	if { $version_changed_p && ![string compare $version_uri $old_version_uri] } {
	    ad_complain
	}
    }
} -errors {
    version_changed_ck {You have changed the version number but not the version URL. When creating
    a package for a new version, you must select a new URL for the version.}
}

db_transaction {
    set version_id [apm_version_update $version_id $version_name $version_uri \
	    $summary $description $description_format $vendor $vendor_uri $release_date]
    apm_package_install_owners [apm_package_install_owners_prepare $owner_name $owner_uri] $version_id
    apm_package_install_spec $version_id
    if {$upgrade_p} {
	apm_version_upgrade $version_id
    }
} on_error {
    ad_return_error "Error" "
I was unable to update your version for the following reason:

<blockquote><pre>[ns_quotehtml $errmsg]</pre></blockquote>
"
}

ad_returnredirect "version-view?version_id=$version_id"

