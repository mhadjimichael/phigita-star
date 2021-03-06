# packages/acs-core-ui/www/acs_object/permissions/index.tcl
ad_page_contract {
    Display permissions and children for the given object_id

    Templated + cross site scripting holes patched by davis@xarg.net

    @author rhs@mit.edu
    @creation-date 2000-08-20
    @cvs-id $Id: one.tcl,v 1.4 2003/01/20 22:35:34 peterm Exp $
} {
    object_id:integer,notnull
    {children_p "f"}
}

set user_id [ad_maybe_redirect_for_registration]
ad_require_permission $object_id admin

set name [ad_quotehtml [db_string name {select acs_object.name(:object_id) from dual}]]

set context [list [list "./" [_ acs-subsite.Permissions]] [_ acs-subsite.Permissions_for_name]]

db_multirow inherited inherited_permissions { *SQL* } { 
    set grantee_name [ad_quotehtml $grantee_name]
}

db_multirow acl acl { *SQL* } {
    set grantee_name [ad_quotehtml $grantee_name]
}

set controls [list]

lappend controls "<a href=grant?[export_url_vars object_id]>[_ acs-subsite.Grant_Permission]</a>"

db_1row context { *SQL* }

if { $security_inherit_p == "t" && ![empty_string_p $context_id] } {
    lappend controls "<a href=toggle-inherit?[export_url_vars object_id]>Don't Inherit Permissions from $context_name</a>"
} else {
    lappend controls "<a href=toggle-inherit?[export_url_vars object_id]>Inherit Permissions from $context_name</a>"
}

set controls "\[ [join $controls " | "] \]"

if [string equal $children_p "t"] {
    db_multirow children children { *SQL* } {
        set c_name [ad_quotehtml $c_name]
    }
} else {
    db_1row children_count { *SQL* } 
}
