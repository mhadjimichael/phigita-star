# packages/acs-core-ui/www/permissions/index.tcl
ad_page_contract {
    Display all objects that the user has admin on.
    
    Templated and changed to browse heirarchy by davis@xarg.net 
    since all objects can be a *lot* of objects.
    
    @author rhs@mit.edu
    @creation-date 2000-08-29
    @cvs-id $Id: index.tcl,v 1.2 2003/01/16 13:40:37 jeffd Exp $
} { 
    root:trim,integer,optional
}

set user_id [ad_maybe_redirect_for_registration]

set context "Permissions"

if {![exists_and_not_null root]} { 
    set root [ad_conn package_id]
}

db_multirow objects adminable_objects { *SQL* }

set security_context_root [acs_magic_object security_context_root]
set default_context [acs_magic_object default_context]
set admin_p [permission::permission_p -object_id $security_context_root -party_id $user_id -privilege admin]
set subsite [ad_conn package_id]
