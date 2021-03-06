ad_page_contract {
    Show the contents of one cached entry
} {
    key:allhtml
    pattern
    raw_date
}

if {[catch {set pair [ns_cache_eval util_memoize $key {}] } errmsg]} {
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
	set value "<i>could not retrieve</i>"
	set time "?"
    }
} else {
    set value [ad_quotehtml [lindex $pair 1]]
    set time [clock format [lindex $pair 0]]
}

set safe_key [ad_quotehtml $key]

regsub -all -nocase -- $pattern $key \
	"<font color=\"#990000\"><b>$pattern</b></font>" key

