ad_page_contract {
    Adds a parameter to a version.
    @author Todd Nightingale (tnight@arsdigita.com)
    @author Bryan Quinn (bquinn@arsdigita.com)
    @date 10 September 2000
    @cvs-id $Id: parameter-edit-2.tcl,v 1.1.1.1 2002/11/22 09:47:32 nkd Exp $
} {
    version_id:naturalnum,notnull
    parameter_id:naturalnum,notnull
    package_key:notnull
    parameter_name:notnull
    section_name
    description:notnull,nohtml
    datatype:notnull
    {default_value [db_null]}
    {min_n_values:integer 1}
    {max_n_values:integer 1}
} -validate {
    datatype_type_ck {
	if {$datatype != "number" && $datatype != "string"} {
	    ad_complain
	}
    }
} -errors {
    datatype_type_ck {The datatype must be either a number or a string.}
}

db_transaction {  
    ns_log Debug "APM: Updating Parameter: $parameter_id, $parameter_name $description, $package_key, $default_value, $datatype, $section_name, $min_n_values, $max_n_values"


    apm_parameter_update $parameter_id $package_key $parameter_name $description \
	    $default_value $datatype $section_name $min_n_values $max_n_values
    apm_generate_package_spec $version_id
} on_error {
    ad_return_error "Database Error" "The parameter could not be updated.  
The database returned the following error:<p>
 <blockquote><pre>[ad_quotehtml $errmsg]</pre></blockquote>"
} 

ad_returnredirect version-parameters?[export_url_vars version_id]
