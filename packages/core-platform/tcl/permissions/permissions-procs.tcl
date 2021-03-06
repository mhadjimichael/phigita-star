ad_library {

    Tcl procs for the acs permissioning system.

    @author rhs@mit.edu
    @creation-date 2000-08-17
    @cvs-id $Id: acs-permissions-procs.tcl,v 1.12 2003/01/29 15:50:06 peterm Exp $

}

namespace eval permission {

    # define cache_p to be 0 here.  Note that it is redefined on init to be 
    # the value of the PermissionCacheP kernel parameter.
    # see request-processor-init.tcl
    ad_proc cache_p {} {
        returns 0 or 1 depending if permission_p caching is enabled or disabled.
        by default caching is disabled.
    } { 
        return 1
    }
        
    ad_proc -public grant {
        {-party_id:required}
        {-object_id:required}
        {-privilege:required}
    } {
        grant privilege Y to party X on object Z
    } {
        db_exec_plsql grant_permission {
	    select acs_permission__grant_permission(
                    :object_id,
                    :party_id,
                    :privilege
                );
	}
        util_memoize_flush "permission::permission_p_not_cached -party_id $party_id -object_id $object_id -privilege $privilege"
    }

    ad_proc -public revoke {
        {-party_id:required}
        {-object_id:required}
        {-privilege:required}
    } {
        revoke privilege Y from party X on object Z
    } {
        db_exec_plsql revoke_permission {
             select acs_permission__revoke_permission(
                    :object_id,
                    :party_id,
                    :privilege
                );
	}
        util_memoize_flush "permission::permission_p_not_cached -party_id $party_id -object_id $object_id -privilege $privilege"
    }

    # args to permission_p and permission_p_no_cache must match
    ad_proc -public permission_p {
        {-no_cache:boolean}
        {-party_id ""}
        {-object_id:required}
        {-privilege:required}
    } {
        does party X have privilege Y on object Z
        
        @param nocache force loading from db even if cached (flushes cache as well)
        @param party_id if null then it is the current user_id
    } {
        if {[empty_string_p $party_id]} {
            set party_id [ad_conn user_id]
        }
        if { $no_cache_p || ![permission::cache_p] } {
            util_memoize_flush "permission::permission_p_not_cached -party_id $party_id -object_id $object_id -privilege $privilege"
            return [permission::permission_p_not_cached -party_id $party_id -object_id $object_id -privilege $privilege]
        } else { 
            return [util_memoize "permission::permission_p_not_cached -party_id $party_id -object_id $object_id -privilege $privilege" 600]
        }
    }


    # accepts nocache to match permission_p arguments 
    # since we alias it to permission::permission_p if
    # caching disabled.
    ad_proc -private permission_p_not_cached {
        {-no_cache:boolean}
        {-party_id ""}
        {-object_id:required}
        {-privilege:required}
    } {
        does party X have privilege Y on object Z

        @see permission::permission_p
    } {
        if {[empty_string_p $party_id]} {
            set party_id [ad_conn user_id]
        }

	set q_object_id [ns_dbquotevalue $object_id]
	set q_party_id [ns_dbquotevalue $party_id]
	set q_privilege [ns_dbquotevalue $privilege]

        return [::xo::db::0or1row -statement_name select_permission_p \
		    "select 1 where 't' = acs_permission__permission_p(${q_object_id}, ${q_party_id}, ${q_privilege})"]
    }

    ad_proc -public require_permission {
        {-party_id ""}
        {-object_id:required}
        {-privilege:required}
    } {
        require that party X have privilege Y on object Z
    } {
        if { ${party_id} eq {} } {
            set party_id [ad_conn user_id]
        }

        if {![permission_p -party_id $party_id -object_id $object_id -privilege $privilege]} {
            if {!${party_id}} {
                ad_maybe_redirect_for_registration
            } else {
                ns_log notice "$party_id doesn't have $privilege on object $object_id"
                ad_return_forbidden \
                    "Security Violation" \
                    "<blockquote>
  You don't have permission to $privilege [db_string name {select acs_object__name(:object_id) from dual}].
  <br>
  This incident has been logged.
</blockquote>"
            }

            ad_script_abort
        }
    }

    ad_proc -public inherit_p {
        {-object_id:required}
    } {
        does this object inherit permissions
    } {
        return [db_string select_inherit_p {
            select case when security_inherit_p = 't' then 1 else 0 end
            from acs_objects
            where object_id = :object_id
	} -default 0]
    }

    ad_proc -public toggle_inherit {
        {-object_id:required}
    } {
        toggle whether or not this object inherits permissions from it's parent
    } {
        db_dml toggle_inherit {
            update acs_objects
            set security_inherit_p = not security_inherit_p
            where object_id = :object_id
	}
    }

    ad_proc -public set_inherit {
        {-object_id:required}
    } {
        set inherit to true
    } {
        db_dml set_inherit {
            update acs_objects
            set security_inherit_p = 't'
            where object_id = :object_id
	}
    }

    ad_proc -public set_not_inherit {
        {-object_id:required}
    } {
        set inherit to false
    } {
        db_dml set_not_inherit {
            update acs_objects
            set security_inherit_p = 'f'
            where object_id = :object_id
	}
    }

}

ad_proc -deprecated ad_permission_grant {
    user_id
    object_id
    privilege
} {
    Grant a permission

    @author ben@openforce.net

    @see permission::grant
} {
    permission::grant -party_id $user_id -object_id $object_id -privilege $privilege
}

ad_proc -deprecated ad_permission_revoke {
    user_id
    object_id
    privilege
} {
    Revoke a permission

    @author ben@openforce.net

    @see permission::revoke
} {
    permission::revoke -party_id $user_id -object_id $object_id -privilege $privilege
}

ad_proc -deprecated ad_permission_p {
    {-user_id ""}
    object_id
    privilege
} { 
    @see permission::permission_p
} {
    return [permission::permission_p -party_id $user_id -object_id $object_id -privilege $privilege]
}

ad_proc -deprecated ad_require_permission {
  object_id
  privilege
} {
    @see permission::require_permission
} { 
    permission::require_permission -object_id $object_id -privilege $privilege
}

ad_proc -private ad_admin_filter {} {
    permission::require_permission -object_id [ad_conn object_id] -privilege "admin"
    return filter_ok
}

ad_proc -private ad_user_filter {} {
    permission::require_permission -object_id [ad_conn object_id] -privilege "read"
    return filter_ok
}
