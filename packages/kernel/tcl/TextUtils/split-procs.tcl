### http://cvs.sourceforge.net/cgi-bin/viewcvs.cgi/tcllib/tcllib/modules/textutil/split.tcl

########################################################################
# This one was written by Bob Techentin (RWT in Tcl'ers Wiki):
# http://www.techentin.net
# mailto:techentin.robert@mayo.edu
#
# Later, he send me an email stated that I can use it anywhere, because
# no copyright was added, so the code is defacto in the public domain.
#
# You can found it in the Tcl'ers Wiki here:
# http://mini.net/cgi-bin/wikit/460.html
#
# Bob wrote:
# If you need to split string into list using some more complicated rule
# than builtin split command allows, use following function. It mimics
# Perl split operator which allows regexp as element separator, but,
# like builtin split, it expects string to split as first arg and regexp
# as second (optional) By default, it splits by any amount of whitespace. 
# Note that if you add parenthesis into regexp, parenthesed part of separator
# would be added into list as additional element. Just like in Perl. -- cary 
#
# Speed improvement by Reinhard Max:
# Instead of repeatedly copying around the not yet matched part of the
# string, I use [regexp]'s -start option to restrict the match to that
# part. This reduces the complexity from something like O(n^1.5) to
# O(n). My test case for that was:
# 
# foreach i {1 10 100 1000 10000} {
#     set s [string repeat x $i]
#     puts [time {splitx $s .}]
# }
#

proc splitx {str {regexp {[\t \r\n]+}}} {
    # Bugfix 476988
    if {[string length $str] == 0} {
	return {}
    }
    if {[string length $regexp] == 0} {
	return [::split $str ""]
    }
    set list  {}
    set start 0
    while {[regexp -start $start -indices -- $regexp $str match submatch]} {
	foreach {subStart subEnd} $submatch break
	foreach {matchStart matchEnd} $match break
	incr matchStart -1
	incr matchEnd
	lappend list [string range $str $start $matchStart]
	if {$subStart >= $start} {
	    lappend list [string range $str $subStart $subEnd]
	}
	set start $matchEnd
    }
    lappend list [string range $str $start end]
    return $list
}
