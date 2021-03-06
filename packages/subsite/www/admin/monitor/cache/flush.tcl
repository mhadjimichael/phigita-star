ad_page_contract {
    Flush one or more values from util_memoize's cache
} {
    type
    pattern
    raw_date
    key:allhtml
}

if {[catch {set pair [ns_cache_eval util_memoize $key {}]} errmsg]} {
    # backup plan, find it again because the key doesn't always 
    # pass through cleanly
    set cached_names [ns_cache_keys util_memoize]
    foreach name $cached_names {
	if {[regexp -nocase -- $pattern $name match]} {
	    set pair [ns_cache_eval util_memoize $name {}]
	    set raw_time [lindex $pair 0]
	    if {$raw_time == $raw_date} {
		set value [ad_quotehtml [lindex $pair 1]]
		set time [clock format $raw_time]
		set key $name
		break
	    }
	}
    }

    if {![info exists value] || [string equal "" $value]} {
	ad_return_complaint 1 "Could not retrieve"
    }
}


ns_cache_flush util_memoize $key

ad_returnredirect "show-util-memoize?pattern=$pattern"