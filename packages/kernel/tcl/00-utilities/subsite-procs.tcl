# /packages/subsite/tcl/subsite-procs.tcl

ad_library {

    Procs to manage application groups

    @author oumi@arsdigita.com
    @creation-date 2001-02-01
    @cvs-id $Id: subsite-procs.tcl,v 1.1.1.1 2002/11/22 09:47:33 nkd Exp $

}

namespace eval subsite {
    namespace eval util {}
}


ad_proc -public acs_subsite_post_instantiation { 
    package_id
} {
    This is the TCL proc that is called automatically by the APM
    whenever a new instance of the subsites application is created.

    @author Michael Bryzek (mbryzek@arsdigita.com)
    @creation-date 2000-03-05

    @param package_id The package_id of the newly mounted subsites
    application

} {
    subsite::configure_if_necessary -package_id $package_id
}



    ad_proc subsite::configure_if_necessary {
	{-package_id ""}
    } {
	Performs post-install configuration if necessary.
	See subsite::configured_p to learn how we determine if a subsite has 
	already been configured.  See subsite::configure to learn what
	is involved in configuring a subsite.

	<p>

	NOTE: this proc might not work without a connection (i.e., 
        [ad_conn isconnected]==1). I haven't tested it without a connection,
	but I think the code would work right now (assuming the caller passes
	in a valid package_id). However, in the future, this proc may redirect
	the administrator to a configuration "wizard" in case we need or want
	some input from the admin to properly configure the subsite.

	@author Oumi Mehrotra (oumi@arsdigita.com)
	@creation-date 2000-02-05

	@param package_id The package_id of the subsite application instance
	to configure.  If package_id is not specified, then 
	<code>[ad_conn package_id]</code> will be used.

    } {
	if {![configured_p -package_id $package_id]} {
	    configure -package_id $package_id
	}

    }


    ad_proc subsite::configured_p {
	{-package_id ""}
    } {
	Determines whether a subsite has been configured.  Returns 1 if
	configured, or 0 otherwise.  Right now, a subsite is considered
	to be configured if its application group exists.  In the future,
	we may store an explicit "configured_p" setting in the DB.

	@author Oumi Mehrotra (oumi@arsdigita.com)
	@creation-date 2000-02-05

	@param package_id The package_id of the subsite application instance
	to configure.  If package_id is not specified, then 
	<code>[ad_conn package_id]</code> will be used.
    } {
	if {[empty_string_p [application_group::group_id_from_package_id \
		-no_complain \
		-package_id $package_id]]} {
	    return 0
	}
	return 1
    }



    ad_proc subsite::configure {
	{-package_id ""}
    } {
	Configures a subsite.  This involves 3 steps:

	<ul>
        <li> Create application group
        <li> Create segment "Subsite Users"
        <li> Create relational constraint to make subsite registration 
             require supersite registration.
	</ul>

	@author Oumi Mehrotra (oumi@arsdigita.com)
	@creation-date 2000-02-05

	@param package_id The package_id of the subsite application instance
	to configure.  If package_id is not specified, then 
	<code>[ad_conn package_id]</code> will be used.

    } {

	if {[ad_conn isconnected]} {
	    if {[empty_string_p $package_id]} {
		set package_id [ad_conn package_id]
	    }
	}

	if {[empty_string_p $package_id]} {
	    error "subsite::configure - package_id not specified"
	}

	set subsite_name [db_string subsite_name_query {
	    select instance_name
	    from apm_packages
	    where package_id = :package_id
	}]

	set truncated_subsite_name [string range $subsite_name 0 89]

	db_transaction {

	    # Create subsite application group
	    set group_name "$truncated_subsite_name Parties"
	    set subsite_group_id [application_group::new \
		    -package_id $package_id \
		    -group_name $group_name]

	    # Create segment of registered users
	    set segment_name "$truncated_subsite_name Members"
	    set segment_id [rel_segments_new $subsite_group_id membership_rel $segment_name]

	    # Create constraint that says "to be a member of this
	    # subsite, you have to be a member of the parent subsite"

	    set supersite_group_id ""

	    db_0or1row parent_subsite_query {
		select m.group_id as supersite_group_id,
                       p.instance_name as supersite_name
		from application_group_element_map m,
                     apm_packages p
		where p.package_id = m.package_id
                  and container_id = group_id
                  and element_id = :subsite_group_id
                  and rel_type = 'composition_rel'
	    } 

	    # First get parent application group's id and instance name
	    if { ![empty_string_p $supersite_group_id] } {

		set constraint_name "Members of [string range $subsite_name 0 30] must be members of [string range $supersite_name 0 30]"
	    
		if {[ad_conn isconnected]} {
		    set user_id [ad_conn user_id]
		    set creation_ip [ad_conn peeraddr]
		} else {
		    set user_id ""
		    set creation_ip ""
		}
		
		set constraint_id [db_exec_plsql add_constraint {
		    BEGIN
			:1 := rel_constraint.new(
			constraint_name => :constraint_name,
			rel_segment => :segment_id,
			rel_side => 'two',
			required_rel_segment => rel_segment.get(:supersite_group_id, 'membership_rel'),
			creation_user => :user_id,
			creation_ip => :creation_ip
			);
		    END;
		}]
	    }
	}

    }



ad_proc -private subsite::instance_name_exists_p {
    node_id
    instance_name 
} { 
    Returns 1 if the instance_name exists at this node. 0
    otherwise. Note that the search is case-sensitive.

    @author Michael Bryzek (mbryzek@arsdigita.com)
    @creation-date 2001-03-01

} {
    return [db_string select_name_exists_p {
	select count(*) 
	  from site_nodes
	 where parent_id = :node_id
	   and name = :instance_name
    }]
}


ad_proc -public subsite::auto_mount_application { 
    { -instance_name "" }
    { -pretty_name "" }
    { -node_id "" }
    package_key
} {
    Mounts a new instance of the application specified by package_key
    beneath node_id
    
    @author Michael Bryzek (mbryzek@arsdigita.com)
    @creation-date 2001-02-28

    @param instance_name The name to use for the url in the
    site-map. Defaults to the package_key plus a possible digit to
    serve as a unique identifier (e.g. news-2)
    
    @param pretty_name The english name to use for the site-map and
    for things like context bars. Defaults to the name of the object
    mounted at this node + the package pretty name (e.g. Intranet News)

    @param node_id Defaults to [ad_conn node_id]

    @return The package id of the newly mounted package 

} {
    if { [empty_string_p $node_id] } {
	set node_id [ad_conn node_id]
    }

    set ctr 2
    if { [empty_string_p $instance_name] } {
	# Default the instance name to the package key. Add a number,
	# if necessary, until we find a unique name
	set instance_name $package_key
	while { [subsite::instance_name_exists_p $node_id $instance_name] } {
	    set instance_name "$package_key $ctr"
	    incr ctr
	}
	# Convert spaces to dashes
	regsub -all { } $instance_name "-" instance_name
    }

    if { [empty_string_p $pretty_name] } {
	# Get the name of the object mounted at this node
	db_1row select_package_object_names {
	    select t.pretty_name as package_name, acs_object.name(s.object_id) as object_name
	      from site_nodes s, apm_package_types t
	     where s.node_id = :node_id
	       and t.package_key = :package_key
	}
	set pretty_name "$object_name $package_name"
	if { $ctr > 2 } {	    
	    # This was a duplicate pkg name... append the ctr used in the instance name
	    append pretty_name " [expr $ctr - 1]"
	}
    }

    return [site_node_mount_application -return package_id $node_id $instance_name $package_key $pretty_name]

}

ad_proc subsite::util::sub_type_exists_p {
    object_type
} {
    returns 1 if object_type has sub types, or 0 otherwise

    @author Oumi Mehrotra (oumi@arsdigita.com)
    @creation-date 2000-02-07
    
    @param object_type

} {

    return [db_string sub_type_exists_p {
	select case 
                 when exists (select 1 from acs_object_types 
                              where supertype = :object_type)
                 then 1 
                 else 0 
               end
        from dual
    }]

}


ad_proc subsite::util::object_type_path_list {
    object_type
    {ancestor_type acs_object}
} {

} {
    set path_list [list]

    set type_list [db_list select_object_type_path {
	select object_type
	from acs_object_types
	start with object_type = :object_type
	connect by object_type = prior supertype
    }]

    foreach type $type_list {
	lappend path_list $type
	if {[string equal $type $ancestor_type]} {
	    break
	}
    }

    return $path_list

}

ad_proc subsite::util::object_type_pretty_name {
    object_type
} {
    returns pretty name of object.  We need this so often that I thought
    I'd stick it in a proc so it can possibly be cached later.

    @author Oumi Mehrotra (oumi@arsdigita.com)
    @creation-date 2000-02-07
    
    @param object_type
} {
    return [db_string select_pretty_name {
	select pretty_name from acs_object_types 
	where object_type = :object_type
    }]
}

ad_proc subsite::util::return_url_stack {
    return_url_list
} {
    Given a list of return_urls, we recursively encode them into one
    return_url that can be redirected to or passed into a page.  As long 
    as each page in the list does the typical redirect to return_url, then
    the page flow will go through each of the pages in $return_url_list
} {

    if {[llength $return_url_list] == 0} {
	error "subsite::util::return_url_stack - \$return_url_list is empty"
    }

    set first_url [lindex $return_url_list 0]
    set rest [lrange $return_url_list 1 end]

    # Base Case
    if {[llength $rest] == 0} {
	return $first_url
    }

    # More than 1 url was in the list, so recurse
    if {[string first ? $first_url] == -1} {
	append first_url ?
    }
    append first_url "&return_url=[ad_urlencode [return_url_stack $rest]]"

    return $first_url
}
