namespace eval ::persistence {

    variable base_dir 

    set base_dir "/web/data"

    array set ks [list]
    array set cf [list]

}



proc ::persistence::get_keyspace_dir {keyspace} {

    variable base_dir
    set keyspace_dir ${base_dir}/${keyspace}
    return ${keyspace_dir}

}


proc ::persistence::get_cf_dir {keyspace column_family} {
    set keyspace_dir [get_keyspace_dir ${keyspace}]
    set cf_dir ${keyspace_dir}/${column_family}
    return ${cf_dir}
}



proc ::persistence::exists_ks_p {keyspace} {

    variable ks

    #return [file isdirectory [get_keyspace_dir ${keyspace}]]
    return [info exists ks(${keyspace})]

}


proc ::persistence::assert_ks {keyspace} {
    if { ![exists_ks_p ${keyspace}] } {
	error "assert_ks: no such keyspace (${keyspace})"
    }
}


proc ::persistence::exists_cf_p {keyspace column_family} {

    variable ks
    variable cf

    #return [file isdirectory [get_cf_dir ${keyspace} ${column_family}]]
    return [info exists cf(${keyspace},${column_family})]

}

proc ::persistence::assert_cf {keyspace column_family} {
    if { ![exists_cf_p ${keyspace} ${column_family}] } {
	error "assert_cf: no such column family (${keyspace},${column_family})"
    }
}


proc ::persistence::create_ks_if {keyspace {replication_factor "3"}} {

    if { ![exists_ks_p ${keyspace}] } {
	file mkdir [get_keyspace_dir ${keyspace}]
	return 1
    }

    return 0

}


proc ::persistence::create_cf_if {keyspace column_family} {

    if { ![exists_cf_p ${keyspace} ${column_family}] } {
	file mkdir [get_cf_dir ${keyspace} ${column_family}]
	return 1
    }

    return 0

}


proc ::persistence::define_ks {keyspace} {

    variable ks

    create_ks_if ${keyspace}

    set ks(${keyspace}) 1
    
}


proc ::persistence::define_cf {keyspace column_family} {

    variable cf

    if { ![exists_ks_p ${keyspace}] } {
	error "define_cf: no such keyspace (${keyspace})"
    }

    create_cf_if ${keyspace} ${column_family}

    set cf(${keyspace},${column_family}) 1

}

proc ::persistence::get_row {keyspace column_family row_key} {

    # aka snapshot directory
    set cf_dir [get_cf_dir ${keyspace} ${column_family}]

    # TODO: depending on keyspace settings, 
    # we can setup other storage strategies

    set row_dir ${cf_dir}/${row_key}

    return ${row_dir}

}



proc ::persistence::create_row_if {keyspace column_family row_key row_dirVar} {

    upvar ${row_dirVar} row_dir

    # ensure keyspace exists
    if { ![exists_ks_p ${keyspace}] } {
	error "create_row_if: no such keyspace (${keyspace})"
    }

    # ensure ${cf_dir} exists
    if { ![exists_cf_p ${keyspace} ${column_family}] } {
	error "create_row_if: no such column family (${keyspace},${column_family})"
    }

    set row_dir [get_row ${keyspace} ${column_family} ${row_key}]

    # create ${row_dir} dir
    file mkdir ${row_dir}

}

# example column families and column names:
#
# cf=news_item url/3ef3908e7438635a03e2321669b5855dbf4f238f
# cf=news_item item keywspace:newsdb log/row:3ef3908e7438635a03e2321669b5855dbf4f238f
# cf=content_item keyspace:newsdb content/row:cdaa22d5ca05c6111d900ce81f5686c376a50881
#
# cf=revision     keyspace:newsdb site/row:com.philenews/super:3ef3908e7438635a03e2321669b5855dbf4f238f/column:cdaa22d5ca05c6111d900ce81f5686c376a50881
# cf=revision     keywspace:newsdb site/row:com.philenews.3ef3908e7438635a03e2321669b5855dbf4f238f/cdaa22d5ca05c6111d900ce81f5686c376a50881
#
# name := keyspace/row_key/column_path
# column_path := super_column_name/column_name or just column_name
#
proc ::persistence::insert_column {keyspace column_family row_key column_path data {timestamp ""}} {

    create_row_if ${keyspace} ${column_family} ${row_key} row_dir

    # path to file that will hold the data
    set filename ${row_dir}/${column_path}

    #puts "filename = $filename"

    # if it applies, mkdir super_column_dir
    if { [set super_column_dir [file dirname ${filename}]] ne ${row_dir} } {

	# it's a supecolumn
	file mkdir ${super_column_dir}

    }

    set_data ${filename} ${data}

    if { ${timestamp} ne {} } {
	file mtime ${filename} ${timestamp}
    }

}


proc ::persistence::exists_data_p {filename} {

    return [file exists ${filename}]

}

# TODO: consider renaming it to put_data
proc ::persistence::set_data {filename data} {

    file mkdir [file dirname ${filename}]

    return [::util::writefile ${filename} ${data}]

}

proc ::persistence::get_data {filename} {

    return [::util::readfile ${filename}]

}

proc ::persistence::get_name {filename_or_dir} {

    return [file tail ${filename_or_dir}]

}

proc ::persistence::delete_data {filename_or_dir} {

    return [file delete ${filename_or_dir}]

}


proc ::persistence::empty_row_p {row_dir} {
    return [expr { [glob -nocomplain -directory ${row_dir} *] eq {} }]
}


proc predicate=lrange {slicelistVar offset {limit ""}} {

    upvar ${slicelistVar} slicelist

    set first ${offset}

    set last "end"
    if { ${limit} ne {} } {
	set last [expr { ${offset} + ${limit} - 1 }]
    }

    set slicelist [lrange ${slicelist} ${first} ${last}]
    
}

proc predicate=lindex {slicelistVar index} {

    upvar ${slicelistVar} slicelist

    set slicelist [lindex ${slicelist} ${index}]

}

proc predicate=in {slicelistVar column_names} {

    upvar ${slicelistVar} slicelist

    set result [list]

    foreach filename ${slicelist} {

	if { [file tail ${filename}] in ${column_names} } {
	    lappend result ${filename}
	}
    }

    set slicelist ${result}

}

proc predicate=lsort {slicelistVar args} {

    set slicelist [lsort {*}${args} ${slicelist}]

}


proc ::persistence::get_multirow {keyspace column_family {predicate ""}} {


    assert_cf ${keyspace} ${column_family}


    set cf_dir [get_cf_dir ${keyspace} ${column_family}]

    set multirow [lsort -decreasing [glob -nocomplain -directory ${cf_dir} *]]

    if { ${predicate} ne {} } {

	lassign ${predicate} cmd args

	predicate=${cmd} multirow {*}${args}

    }

    return ${multirow}

}

proc ::persistence::get_multirow_names {args} {

    set multirow [get_multirow {*}${args}]
    set result [list]
    foreach row ${multirow} {
	lappend result [get_name ${row}]
    }
    return ${result}
}


proc ::persistence::get_multirow_slice {keyspace column_family {multirow_predicate ""} {slice_predicate ""}} {

    set multirow [get_multirow ${keyspace} ${column_family} ${multirow_predicate}]

    set multirow_slice [list]

    foreach row_dir ${multirow} {

	set slicelist [get_slice_from_row ${row_dir} ${slice_predicate}]

	lappend multirow_slice ${slicelist}

    }

    return ${multirow_slice}
}


proc ::persistence::get_multirow_slice_names {args} {

    set multirow_slice [get_multirow_slice {*}${args}]

    set multirow_slice_names [list]
    foreach slicelist ${multirow_slice} {
	set names [list]
	foreach filename ${slicelist} {
	    lappend names [::persistence::get_name ${filename}]
	}
	lappend multirow_slice_names ${names}
    }
    return ${multirow_slice_names}

}

proc ::persistence::get_slice_from_row {row_dir {slice_predicate ""}} {

    set slicelist [lsort -decreasing [glob -nocomplain -directory ${row_dir} *]]

    if { ${slice_predicate} ne {} } {

	lassign ${slice_predicate} cmd args

	predicate=${cmd} slicelist {*}${args}

    }

    return ${slicelist}

}

proc ::persistence::get_slice {keyspace column_family row_key {slice_predicate ""}} {

    set row_dir [get_row ${keyspace} ${column_family} ${row_key}]

    return [get_slice_from_row ${row_dir} ${slice_predicate}]

}

proc ::persistence::get_slice_names {args} {

    set result [list]

    set slicelist [get_slice {*}${args}]

    foreach filename ${slicelist} {

	lappend result [::persistence::get_name ${filename}]

    }

    return ${result}

}


proc ::persistence::get_column {keyspace column_family row_key column_path {dataVar ""} {exists_pVar ""}} {

    set row_dir [get_row ${keyspace} ${column_family} ${row_key}]

    set filename ${row_dir}/${column_path}

    # puts "filename = $filename"

    if { ${dataVar} ne {} } {

	if { ${exists_pVar} ne {} } {

	    upvar ${exists_pVar} exists_p

	}

	set exists_p [exists_data_p ${filename}]

	if { ${exists_p} } {

	    upvar ${dataVar} data

	    set data [get_data ${filename}]

	}

    }

    return ${filename}

}

proc ::persistence::get_column_name {args} {

    set result [list]

    set column [get_column {*}${args}]

    set result [file tail ${column}]

    return ${result}

}


proc ::persistence::delete_column {args} {

    set filename [get_column {*}${args}]

    delete_data ${filename}

}

proc ::persistence::delete_row {args} {
    
    set row_dir [get_row {*}${args}]

    delete_data ${row_dir}

}

proc ::persistence::delete_row_if {args} {
    set row_dir [get_row {*}${args}]

    set empty_row_p [empty_row_p ${row_dir}]

    if { ${empty_row_p} } {
	delete_data ${row_dir}
    }

    return ${empty_row_p}
}


proc ::persistence::delete_slice {keyspace column_family row_key {slice_predicate ""}} {

    set row_dir [get_row ${keyspace} ${column_family} ${row_key}]
    set slicelist [get_slice_from_row ${row_dir} ${slice_predicate}]

    foreach filename ${slicelist} {
	::persistence::delete_data ${filename}
    }


    if { [empty_row_p ${row_dir}] } {
	delete_data ${row_dir}
    }

    return ${slicelist}
}


proc ::persistence::exists_column_p {keyspace column_family row_key column_path} {

    set row_dir [get_row ${keyspace} ${column_family} ${row_key}]

    set filename ${row_dir}/${column_path}

    return [file exists ${filename}]

}


proc ::persistence::multiget_slice {keyspace column_family row_keys {slice_predicate ""}} {

    set result [list]

    foreach row_key ${row_keys} {

	set slicelist [get_slice ${keyspace} ${column_family} ${row_key} ${slice_predicate}]

	lappend result ${row_key}
	lappend result ${slicelist}

    }

    return ${result}

}




#TODO: get_range_slices
#TODO: batch_mutate
#TODO: incr_column
#TODO: incr_super_column
