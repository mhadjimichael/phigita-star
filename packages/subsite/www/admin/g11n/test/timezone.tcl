#/packages/lang/www/test.tcl
ad_page_contract {

    Tests procedures in the lang package

    @author John Lowry (lowry@ardigita.com)
    @creation-date 29 September 2000
    @cvs-id $Id: timezone.tcl,v 1.1 2002/10/07 14:32:49 lars Exp $
} { }

set title "Test acs-lang package timezones"
set header [ad_header $title]
# set navbar [ad_context_bar "Test"]
set footer [ad_footer]


# Test 3 checks that the timezone tables are installed
# Need this data to check that test 4 works
set tz_sql "SELECT tz as timezone
                   ,local_start
                   ,local_end
                   ,ROUND(timezones.gmt_offset * 24) as utc_offset
              FROM timezone_rules, timezones
             WHERE timezones.tz = 'Europe/Paris'
                   and timezone_rules.tz_id = timezones.tz_id
               AND local_start > sysdate - 365
               AND local_end < sysdate + 365
          ORDER BY local_start"
db_multirow tz_results lang_tz_get_data $tz_sql

# Test 4 checks that we can convert from local time to UTC
db_1row lang_system_time_select "SELECT to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS') AS system_time FROM dual"

set NYC_time [lc_time_utc_to_local $system_time "America/New_York"]
set NYC_utc_time [lc_time_local_to_utc $NYC_time "America/New_York"]
if {[string compare $system_time $NYC_utc_time] == 0} {
    set NYC_p "OK"
} else {
    set NYC_p "<font color=red>FAILED</font>"
}


set LA_time [lc_time_utc_to_local $system_time "America/Los_Angeles"]
set LA_utc_time [lc_time_local_to_utc $LA_time "America/Los_Angeles"]
if {[string compare $system_time $LA_utc_time] == 0} {
    set LA_p "OK"
} else {
    set LA_p "<font color=red>FAILED</font>"
}

set paris_time [lc_time_utc_to_local $system_time "Europe/Paris"]
set paris_utc_time [lc_time_local_to_utc $paris_time "Europe/Paris"]
if {[string compare $system_time $paris_utc_time] == 0} {
    set paris_p "OK"
} else {
    set paris_p "<font color=red>FAILED</font>"
}

set tokyo_time [lc_time_utc_to_local $system_time "Asia/Tokyo"]
set tokyo_utc_time [lc_time_local_to_utc $tokyo_time "Asia/Tokyo"]
if {[string compare $system_time $tokyo_utc_time] == 0} {
    set tokyo_p "OK"
} else {
    set tokyo_p "<font color=red>FAILED</font>"
}


ad_return_template

