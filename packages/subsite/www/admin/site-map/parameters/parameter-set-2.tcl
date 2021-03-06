ad_page_contract {

    Set parameters on a package instance.

    @author Bryan Quinn (bquinn@arsdigita.com)
    @creation-date 12 September 2000
    @cvs-id $Id: parameter-set-2.tcl,v 1.3 2002/09/10 22:22:11 jeffd Exp $

} {
    package_key:notnull
    package_id:naturalnum,notnull
    instance_name:notnull
    params:array
}

ad_require_permission $package_id admin

if { [catch {
    db_foreach apm_parameters_set {} {
	if {[info exists params($parameter_id)]} {
	    ad_parameter -set $params($parameter_id) -package_id $package_id $parameter_name $package_key 
	}
    }
} errmsg] } {
    ad_return_error "Database Error" "The parameters could not be set.  The database error was:<p>
<blockquote><pre>[ad_quotehtml $errmsg]</pre></blockquote>."
} else {
    ad_returnredirect ../
}
