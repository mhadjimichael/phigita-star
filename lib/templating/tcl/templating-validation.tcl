namespace eval ::templating::validation {;}


proc ::templating::validation::check=month {valueVar} {
    upvar ${valueVar} value
    if { [string is integer -strict ${value}] && ${value} >= 1 && ${value} <= 12 } {
	return 1
    }
    return 0
}

proc ::templating::validation::check=year_month {valueVar} {
    upvar ${valueVar} value

    set parts [split ${value} {-}]
    if { [llength ${parts}] == 2 } {
	lassign ${parts} year month
	if { [check=naturalnum year] && [check=month month] } {
	    return 1
	}
    }
    return 0
}

proc ::templating::validation::check=email {valueVar} {
    upvar ${valueVar} value
    set re {^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$}
    if { [regexp -nocase -- ${re} ${value}] } {
	return 1
    }
    return 0
}

proc ::templating::validation::check=uri {valueVar} {
    upvar ${valueVar} value
    set re {^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?$}
    if { [regexp -- ${re} ${value}] } {
	return 1
    }
    return 0
}

proc ::templating::validation::check=url {valueVar} {
    upvar ${valueVar} value

    set re {^(https?|ftp|file)://.+$}
    if { [check=uri value] && [regexp -nocase -- ${re} ${value}] } {
	return 1
    }
    return 0
}

proc ::templating::validation::check=ip {valueVar} {
    upvar ${valueVar} value
    set re {^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$}
    if { [regexp -nocase -- ${re} ${value}] } {
	return 1
    }
    return 0
}


proc ::templating::validation::check=sha1_hex {valueVar} {
    upvar ${valueVar} value
    set re {^[0123456789abcdef]{40}$}
    if { [regexp -nocase -- ${re} ${value}] } {
	return 1
    }
    return 0
}

proc ::templating::validation::check=md5_hex {valueVar} {
    upvar ${valueVar} value
    set re {^[0123456789abcdef]{32}$}
    if { [regexp -nocase -- ${re} ${value}] } {
	return 1
    }
    return 0
}

proc ::templating::validation::check=boolean {valueVar} {
    upvar ${valueVar} value
    return [string is boolean -strict ${value}]
}

proc ::templating::validation::check=notnull {valueVar} {
    upvar ${valueVar} value
    if { $value ne {} } {
	return 1
    }
    return 0
}


# -------------------------------- strings ----------------------------------------

proc ::templating::validation::check=uppercase {valueVar} {
    upvar ${valueVar} value
    if { [string toupper ${value}] eq ${value} } {
	return 1
    }
    return 0
}

proc ::templating::validation::check=lowercase {valueVar} {
    upvar ${valueVar} value
    if { [string tolower ${value}] eq ${value} } {
	return 1
    }
    return 0
}

proc ::templating::validation::check=alpha {valueVar} {
    upvar ${valueVar} value
    return [string is alpha -strict ${value}]
}

proc ::templating::validation::check=alnum {valueVar} {
    upvar ${valueVar} value
    return [string is alnum -strict ${value}]
}

proc ::templating::validation::check=ascii {valueVar} {
    upvar ${valueVar} value
    return [string is ascii -strict ${value}]
}


# -------------------------------- numbers ----------------------------------------

proc ::templating::validation::check=integer {valueVar} {
    upvar ${valueVar} value
    return [string is integer -strict ${value}]
}

proc ::templating::validation::check=naturalnum {valueVar} {
    upvar ${valueVar} value
    if { [string is integer -strict ${value}] && ${value} >= 0 } {
	return 1
    }
    return 0
}

proc ::templating::validation::check=double {valueVar} {
    upvar ${valueVar} value
    return [string is double -strict ${value}]
}

proc ::templating::validation::check=entier {valueVar} {
    upvar ${valueVar} value
    return [string is entier -strict ${value}]
}


proc ::templating::validation::check=float {valueVar} {
    upvar ${valueVar} value
    set re {^[-+]?[0-9]*\.?[0-9]+$}
    if { [regexp -- ${re} ${value}] } {
	return 1
    }
    return 0
}

proc ::templating::validation::check=float_optional_exp {valueVar} {
    upvar ${valueVar} value
    set re {^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$}
    if { [regexp -- ${re} ${value}] } {
	return 1
    }
    return 0
}

# -------------------------------- dates ------------------------------------------

proc ::templating::validation::is_valid_date {valueVar re submatch_vars} {
    upvar ${valueVar} value
    set re {^[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?$}
    if { [regexp -nocase -- ${re} ${value} _dummy_ {*}${submatch_vars}] } {

	if (${day} == 31 and (${month} == 4 || ${month} == 6 || ${month} == 9 || ${month} == 11)) {

	    return 0; # 31st of a month with 30 days

	} elseif (${day} >= 30 && ${month} == 2) {

	    return 0; # February 30th or 31st

	} elseif (${month} == 2 && ${day} == 29 && !(${year} % 4 == 0 && (${year} % 100 != 0 || ${year} % 400 == 0))) {

	    return 0; # February 29th outside a leap year

	} else {

	    return 1; # Valid date

	}

    }
    return 0
}

# matches a date in yyyy-mm-dd format from between 1900-01-01 and 2099-12-31, 
# with a choice of four separators.
# require the delimiters to be consistent, it will match 1999-01-01 but not 1999/01-01
proc ::templating::validation::check=yyyy-mm-dd {valueVar} {
    upvar ${valueVar} value
    set re {^((?:19|20)\d\d)([- /.])(0[1-9]|1[012])\2(0[1-9]|[12][0-9]|3[01])$}
    return [is_valid_date value ${re} {year delimiter month day}]
}

proc ::templating::validation::check=mm-dd-yyyy {valueVar} {
    upvar ${valueVar} value
    set re {^(0[1-9]|1[012])([- /.])(0[1-9]|[12][0-9]|3[01])\2(19|20)\d\d$}
    return [is_valid_date value ${re} {month delimiter day year}]
}

proc ::templating::validation::check=dd-mm-yyyy {valueVar} {
    upvar ${valueVar} value
    set re {^(0[1-9]|[12][0-9]|3[01])([- /.])(0[1-9]|1[012])\2(19|20)\d\d$}
    return [is_valid_date value ${re} {day delimiter month year}]
}



# -------------------------------- credit card numbers ----------------------------
# see http://www.regular-expressions.info/creditcard.html

# All Visa card numbers start with a 4. New cards have 16 digits. Old cards have 13. 
proc ::templating::validation::check=cc_visa {valueVar} {
    upvar ${valueVar} value
    set re {^4[0-9]{12}(?:[0-9]{3})?$}
    if { [regexp -nocase -- ${re} ${value}] } {
	return 1
    }
    return 0
}

# All MasterCard numbers start with the numbers 51 through 55. All have 16 digits. 
proc ::templating::validation::check=cc_mastercard {valueVar} {
    upvar ${valueVar} value
    set re {^5[1-5][0-9]{14}$}
    if { [regexp -nocase -- ${re} ${value}] } {
	return 1
    }
    return 0
}

# American Express card numbers start with 34 or 37 and have 15 digits
proc ::templating::validation::check=cc_amex {valueVar} {
    upvar ${valueVar} value
    set re {^3[47][0-9]{13}$}
    if { [regexp -nocase -- ${re} ${value}] } {
	return 1
    }
    return 0
}

# Diners Club card numbers begin with 300 through 305, 36 or 38. All have 14 digits. 
# There are Diners Club cards that begin with 5 and have 16 digits. 
# These are a joint venture between Diners Club and MasterCard, and should be 
# processed like a MasterCard. 
proc ::templating::validation::check=cc_diners_club {valueVar} {
    upvar ${valueVar} value
    set re {^3(?:0[0-5]|[68][0-9])[0-9]{11}$}
    if { [regexp -nocase -- ${re} ${value}] } {
	return 1
    }
    return 0
}

# Discover card numbers begin with 6011 or 65. All have 16 digits. 
proc ::templating::validation::check=cc_discover {valueVar} {
    upvar ${valueVar} value
    set re {^6(?:011|5[0-9]{2})[0-9]{12}$}
    if { [regexp -nocase -- ${re} ${value}] } {
	return 1
    }
    return 0
}

# JCB cards beginning with 2131 or 1800 have 15 digits. JCB cards beginning with 35 have 16 digits. 

proc ::templating::validation::check=cc_jcb {valueVar} {
    upvar ${valueVar} value
    set re {^(?:2131|1800|35\d{3})\d{11}$}
    if { [regexp -nocase -- ${re} ${value}] } {
	return 1
    }
    return 0
}



# ---------------------------------------------------------------------------------




proc ::templating::validation::check=novirus {valueVar} {
    upvar ${valueVar} value
    # TODO: check with clamav
    if { 0 } {
	return 1
    }
    return 0
}

