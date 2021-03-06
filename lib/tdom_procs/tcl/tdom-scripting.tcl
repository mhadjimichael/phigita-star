namespace eval ::dom {;}

namespace eval ::dom {
    namespace eval _elementNodeCmd {;}
    namespace eval _textNodeCmd {;}
    namespace eval _cdataNode {;}
    namespace eval _commentNode {;}
    namespace eval _piNode {;}
    namespace eval _parserNode {;}
}

proc ::dom::createNodeCmd {node_type node_tag} {
    set nsp "::dom::_${node_type}Cmd"
    namespace eval $nsp [list dom createNodeCmd -returnNodeCmd $node_type $node_tag]
}

proc ::dom::execNodeCmd {node_type node_tag args} {
    set nsp "::dom::_${node_type}Cmd"
    set cmd [list ${nsp}::$node_tag {*}$args]
    set node [uplevel $cmd]
}

# tDOM does not provide such a proc,
# so we had to write one for cases like
# the following:
#
# $doc appendFromScript {
#   dom createNodeInContext elementNode somecmdname
# }
#
proc ::dom::createNodeInContext {node_type node_tag args} {

    set nsp "::dom::_${node_type}Cmd"
    set counter_var "${nsp}::count(${node_tag})"

    namespace eval $nsp {;}

    if { [incr $counter_var] == 1 } {
        set cmd [list dom createNodeCmd -returnNodeCmd $node_type $node_tag]
        namespace eval ${nsp} $cmd
    }

    set cmd [list ${nsp}::$node_tag {*}$args]
    set node [uplevel $cmd]

    if { [incr $counter_var -1] == 0 } {
        rename ${nsp}::$node_tag {}
    }

    return $node

}

proc ::dom::createDocumentFromScript {rootname script} {
    set doc [dom createDocument $rootname]
    $doc appendFromScript $script
    return $doc
}


namespace eval ::dom::scripting {
    namespace export *
}

proc ::dom::scripting::require_procs {} {
    namespace eval ::dom::scripting {
        dom createNodeCmd textNode t
        proc nt {text} { t -disableOutputEscaping ${text} }
        namespace export t nt
    }
}
#::dom::scripting::require_procs

proc ::dom::scripting::node_cmd {cmd_name} {

    set nsp [uplevel { namespace current }]

    namespace eval ${nsp} [list dom createNodeCmd -returnNodeCmd elementNode $cmd_name]

}

proc ::dom::scripting::text_cmd {cmd_name} {

    set nsp [uplevel { namespace current }]

    namespace eval ${nsp} [list dom createNodeCmd -returnNodeCmd textNode $cmd_name]

}


proc ::dom::scripting::textnode_cmd {cmd_name {default_string ""}} {

    set nsp [uplevel { namespace current }]

    set shadow_nsp ${nsp}::_shadow_

    namespace eval $shadow_nsp [list ${nsp}::node_cmd $cmd_name]

    proc ${nsp}::$cmd_name {args} [subst -nocommands -nobackslashes {

        set str {}
        if { [llength [set args]] % 2 == 1 } {
            set str [lindex [set args] end]
            set args [lrange [set args] 0 end-1]
        }

        set node [uplevel [list ${shadow_nsp}::$cmd_name {*}[set args]]]

        if { [set str] ne {} } {
            [set node] appendFromScript { ::dom::scripting::t [set str] }
        }

    }]

}


proc ::dom::scripting::extend_lang {nsp script} {

    set i 0
    while { [info proc ${nsp}::_require_procs_${i}] ne {} } {
        incr i
        if { $i > 100 } {
            error "something is wrong or too many extension to the language"
        }
    }

    rename ${nsp}::require_procs ${nsp}::_require_procs_${i}

    proc ${nsp}::require_procs {} [list ${nsp}::_require_procs_${i}; namespace eval ${nsp} ${script}]

    ${nsp}::require_procs

}

proc ::dom::scripting::require_lang {nsp} {

    if { ![namespace exists ${nsp}] } {
        error "no such namespace / lang"
    }

    ${nsp}::require_procs

}

proc ::dom::scripting::source_inscope {filename nsp} {

    namespace inscope ${nsp} [list source $filename]

}

proc ::dom::scripting::source_tdom {filename nsp {root_element_name ""}} {

    if { $root_element_name eq {} } {

        set ext [file ext $filename]

        set root_element_name [string range $ext 1 end]

    }

    set doc [dom createDocument $root_element_name]

    set ::__source_tdom_doc $doc

    set root [$doc documentElement]

    set script "namespace inscope ${nsp} { source $filename }"

    if { [catch {$root appendFromScript $script} errmsg options] } {

        unset ::__source_tdom_doc

        $doc delete

        array set options_arr $options

        error $errmsg $options_arr(-errorinfo)

    } else {

        unset ::__source_tdom_doc

        return $doc

    }

}

proc ::dom::scripting::validate {lang_nsp node} {

    set dtd [${lang_nsp}::dtd]

    set xml [$node asXML]
    set tmpfile /tmp/somelang.xml
    set fp [open $tmpfile w]
    puts $fp "${dtd}\n${xml}"
    close $fp

    if { [catch {exec /usr/bin/xmllint --valid --noout $tmpfile} errmsg options] } {

        array set options_arr $options

        lassign $options_arr(-errorcode) _childstatus_ _pid_ errorcode

        array set errortext {
            0 "No error"
            1 "Unclassified"
            2 "Error in DTD"
            3 "Validation error"
            4 "Validation error"
            5 "Error in schema compilation"
            6 "Error writing output"
            7 "Error in pattern (generated when --pattern option is used)"
            8 "Error in Reader registration (generated when --chkregister option is used)"
            9 "Out of memory error"
        }

        puts "--->>> $errortext($errorcode)"

        set lines [regsub -all {\n\/} $errmsg "\x01\/"]
        set lines [split $lines "\x01"]
        foreach line $lines {

            lassign [split $line {:}] filename line_number which_element what_error error_message 

            puts "filename: $filename"
            puts "line: $line_number"
            puts "which element: $which_element"
            puts "what error: $what_error"
            puts "error message: $error_message"
        }

    }

}

namespace import -force \
    ::dom::scripting::define_lang \
    ::dom::scripting::require_lang \
    ::dom::scripting::extend_lang \
    ::dom::scripting::source_inscope \
    ::dom::scripting::source_tdom



