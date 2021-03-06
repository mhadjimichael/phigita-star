ad_library {

  @author rhs@mit.edu
  @creation-date 2000-09-09
  @cvs-id $Id: acs-kernel-procs.tcl,v 1.1.1.1 2002/11/22 09:47:31 nkd Exp $
}

ad_proc -public ad_acs_administrator_exists_p {} {
    
    @return 1 if a user with admin privileges exists, 0 otherwise.

} {
    return [::xo::db::value -statement_name admin_exists_p -default 0 {
	select 1 as admin_exists_p
	from dual
	where exists (select 1
		      from acs_object_party_privilege_map m, users u
		      where m.object_id = 0
		      and m.party_id = u.user_id
		      and m.privilege = 'admin')
    }]
}


ad_proc -public ad_acs_admin_node {} {

    @return The node id of the ACS administration service if it is mounted, 0 otherwise.

} {
    # Obtain the id of the ACS Administration node.

    # DRB: this used to say "and rownum = 1" but I've changed it to an SQL92 form
    # that's ummm...portable!

    return [::xo::db::value -statement_name acs_admin_node_p -default 0 {
	select case when count(object_id) = 0 then 0 else 1 end
	from site_nodes
	where object_id = (select package_id 
	                   from apm_packages 
	                   where package_key = 'core-platform')
    }]
}

ad_proc -public ad_verify_install {} {
  Returns 1 if the acs is properly installed, 0 otherwise.
} {
    if { ![db_table_exists apm_packages] || ![db_table_exists site_nodes] } {
	ad_proc util_memoize {script {max_age ""}} {no cache} {eval $script}
	return 0
    }
    set kernel_install_p [apm_package_installed_p core-platform] 
    set admin_exists_p [ad_acs_administrator_exists_p]

    ns_log Notice "Verifying Installation: Kernel Installed? $kernel_install_p \
	    An Administrator? $admin_exists_p"
    ns_log Debug "Verifying Installation: Kernel Installed? $kernel_install_p \
	    An Administrator? $admin_exists_p"

    if { $kernel_install_p && $admin_exists_p} {
	return 1 
    } else {
	ad_proc util_memoize {script {max_age ""}} {no cache} {eval $script}
	return 0
    }
}


