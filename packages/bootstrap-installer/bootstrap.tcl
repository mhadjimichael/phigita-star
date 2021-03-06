# /packages/acs-tcl/bootstrap/bootstrap.tcl
#
# Code to bootstrap OpenACS, invoked by /tcl/0-acs-init.tcl.
#
# @author Neophytos Demetriou


# Remember the length of the error log file (so we can easily seek back to this
# point later). This is used in /www/admin/monitoring/startup-log.tcl to show
# the segment of the error log corresponding to server initialization (between
# "AOLserver/xxx starting" and "AOLserver/xxx running").
catch { nsv_set acs_properties initial_error_log_length [file size [ns_info log]] }

# Initialize proc_doc NSV arrays.
nsv_set proc_source_file . ""

# Initialize ad_after_server_initialization.
nsv_set ad_after_server_initialization . ""

###
#
# Bootstrapping code.
#
###

# A helper procedure called if a fatal error occurs.
proc bootstrap_fatal_error { message { throw_error_p 1 } } {
    # First of all, redefine the "rp_invoke_filter" and "rp_invoke_procs"
    # routines to do nothing, to circumvent the request processor.
    proc rp_invoke_filter { conn arg why } { return "filter_ok" }
    proc rp_invoke_procs { conn arg why } {}

    global errorInfo
    # Save the error message.
    nsv_set bootstrap_fatal_error . "$message<blockquote><pre>[ns_quotehtml $errorInfo]</pre></blockquote>"
    # Log the error message.
    ns_log "Error" "Server startup failed: $message\n$errorInfo"

    # Define a filter procedure which displays the appropriate error message.
    proc bootstrap_write_error { conn arg why } {
	ns_returnerror 503 "Server startup failed: [nsv_get bootstrap_fatal_error .]"
	return "filter_return"
    }

    # Register the filter on GET/POST/HEAD * to return this message.
    ns_register_filter preauth GET * bootstrap_write_error
    ns_register_filter preauth POST * bootstrap_write_error
    ns_register_filter preauth HEAD * bootstrap_write_error

    if { $throw_error_p } {
	return -code error -errorcode bootstrap_fatal_error "Bootstrap fatal error"
    }
}

set errno [catch {

    # Load the special bootstrap tcl library.

    set files [glob -nocomplain "$root_directory/packages/bootstrap-installer/tcl/*-procs.tcl"]
    if { [llength $files] == 0 } {
	error "Unable to locate $root_directory/packages/bootstrap-installer/tcl/*-procs.tcl."
    }

    foreach file [lsort $files] {
	ns_log Notice "Bootstrap: sourcing $file"
	source $file
    }

    db_bootstrap_set_db_type database_problem

    #####
    #
    # Perform some checks to make sure that (a) a recent version of the Oracle or PG driver
    # is installed and (b) the OpenACS data model is properly loaded.
    #
    #####

    # DRB: perform RDBMS-specific sanity checks if the user has survived the database
    # gauntlet thus far.

    if { ![info exists database_problem] } {
        set db_fn "$root_directory/packages/bootstrap-installer/db-init-checks-[nsv_get ad_database_type .].tcl"
        if { ![file isfile $db_fn] } {
            set database_problem "\"$db_fn\" does not exist."
        } else {
            source $db_fn
        }
        db_bootstrap_checks database_problem error_p
    }

    ns_log notice "Loading kernel libraries"
    apm_bootstrap_load_libraries -procs kernel
    apm_bootstrap_load_libraries -procs core-platform
    apm_bootstrap_load_libraries -procs package-manager





    if { [info exists database_problem] } {
	# Yikes - database problems. Remember what the problem is, and run the
	# installer.
	ns_log "Error" $database_problem

	# ND (20110712)
	exit

	nsv_set acs_properties database_problem $database_problem
	ns_log "Notice" "database problem found; Sourcing the installer."
	source "$root_directory/packages/bootstrap-installer/installer.tcl"
	source "$root_directory/packages/bootstrap-installer/installer-init.tcl"
	return
    }

    # Here we need to at least load up queries for the acs-tcl and
    # bootstrap-installer packages (ben)

#    apm_bootstrap_load_queries request-processor
#    apm_bootstrap_load_queries persistence
    apm_bootstrap_load_queries core-platform
#    apm_bootstrap_load_queries form-builder
    apm_bootstrap_load_queries package-manager
#    apm_bootstrap_load_queries security
    apm_bootstrap_load_queries bootstrap-installer

    # Is OpenACS installation complete? If not, source the installer and bail.
    if { ![ad_verify_install] } {
	ns_log "Notice" "Installation is not complete - sourcing the installer."
	source "$root_directory/packages/bootstrap-installer/installer.tcl"
	source "$root_directory/packages/bootstrap-installer/installer-init.tcl"
	return
    }

    # Load all parameters for enabled package instances.
    ad_parameter_cache_all  
    
    # Load the Tcl package init files.
    apm_bootstrap_load_libraries -init kernel
    apm_bootstrap_load_libraries -init core-platform
    apm_bootstrap_load_libraries -init package-manager

    foreach package_key [db_list package_keys_select {
	select package_key from apm_enabled_package_versions
    }] {
	nsv_set apm_enabled_package $package_key 1
    }



    # Load *-procs.tcl and *-init.tcl files for enabled packages.
    apm_load_libraries -procs

    # Load up the Queries (OpenACS, ben@mit.edu)
    #apm_load_queries

    # Load all pdl files for enabled packages.

    apm_load_libraries -init


    apm_bootstrap_load_pdl kernel

    apm_load_pdl_files

    if { ![nsv_exists rp_properties request_count] } {
	# security-init.tcl has not been invoked, so it's safe to say that the
	# core has not been properly initialized and the server will probably
	# fail catastrophically.
	bootstrap_fatal_error "The request processor routines have not been loaded."
    }

    ns_log "Notice" "bootstrap-installer: done loading"
}]

if { $errno && $errno != 2 } {
    # An error occured while bootstrapping. Handle it by registering a filter
    # to display the error message, rather than leaving the site administrator
    # to guess what broke.

    # If the $errorCode is "bootstrap_fatal_error", then the error was explicitly
    # thrown by a call to bootstrap_fatal_error. If not, bootstrap_fatal_error was
    # never called, so we need to call it now.
    global errorCode
    if { [string compare $errorCode "bootstrap_fatal_error"] } {
	bootstrap_fatal_error "Error during bootstrapping" 0
    }
}
