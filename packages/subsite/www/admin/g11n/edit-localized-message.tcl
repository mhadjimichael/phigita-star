ad_page_contract {

    Displays the localized message from the database for translation (displays
    an individual message)

    @author Bruno Mattarollo <bruno.mattarollo@ams.greenpeace.org>
    @author Christian Hvid
    @creation-date 30 October 2001
    @cvs-id $Id: edit-localized-message.tcl,v 1.4 2002/11/12 15:34:23 peterm Exp $

} {
    locales
    message_key
    package_key
    {translated_p 0}
    {return_url "display-localized-messages?[export_vars { package_key locales translated_p }]"}
} -properties {
}
ad_conn_set form_count 0

if {[info exists locales]} {
    set current_locale $locales
} else {
    set current_locale [ad_conn locale]
}

set tab [ns_urlencode "localized-messages"]

set context_bar [ad_context_bar [list "index?tab=$tab" "Locales & Messages"] \
    [list "display-grouped-messages?tab=$tab&locales=$locales" "Listing"] \
    [list "display-localized-messages?[export_vars { package_key locales translated_p }]" "Messages"] "Edit"]


# This has an ugly smell: But let's hardcode the default to en_US

set default_locale en_US

# The part that deals with images is removed - so all messages are treated
# as simple text.

form create message_editing -mode edit -edit_buttons ok -show_required_p y

element create message_editing original_message \
    -label "Original Message" -datatype text -widget inform

element create message_editing message -label "Message" \
    -datatype text -widget textarea -html { rows 6 cols 40 }

# The hidden elements for passing package key, message key and locale

element create message_editing message_key -datatype text -widget hidden

element create message_editing package_key -datatype text -widget hidden

element create message_editing locales -datatype text -widget hidden

element create message_editing translated_p -label "translated_p" -datatype text -widget hidden -value $translated_p
element create message_editing return_url -datatype text -widget hidden -value $return_url

set locale_label [ad_locale_get_label $current_locale]

# Header Stuff ... We make sure that this page doesn't get cached.
set header_stuff "<meta http-equiv=\"Pragma\" content=\"no-cache\" />" 

if { [form is_request message_editing] } {

    set sql_select_original_message {
        select message
        from lang_messages
        where message_key = :message_key and 
              package_key = :package_key and
              locale = :default_locale
    }

    set sql_select_translated_message {
        select message as translated_message
        from   lang_messages
        where  message_key = :message_key and 
               package_key = :package_key and
               locale = :current_locale
    }

    # Let's get the original message (in english)
    #db_1row select_original_message $sql_select_original_message
    set message ${message_key}

    # let's get the translated message (we use 0or1row since the message
    # might not exists
    db_0or1row select_translated_message $sql_select_translated_message

    if { [exists_and_not_null translated_message] } {
        element set_properties message_editing message -value [ad_quotehtml $translated_message]
    } else {
        element set_properties message_editing message -value "No Translation Available"
    }
   
    element set_properties message_editing message_key -value $message_key
    element set_properties message_editing package_key -value $package_key
    element set_properties message_editing locales -value $current_locale
    element set_properties message_editing original_message -value [ad_quotehtml $message]

} else {

    # We are not processing a request, therefor it's a submission. Get the values
    # from the form and validate them

    form get_values message_editing
    if { $message == "" } {

        element set_error message_editing message "Message is required"
        set sql_select_original_message {
            select message
            from   lang_messages
            where  message_key = :message_key and 
                   package_key = :package_key and
                   locale = :default_locale
        }

        db_1row select_original_message $sql_select_original_message

        element set_properties message_editing original_message -value $message

    }

}


if { [form is_valid message_editing] } {
    # We get the values from the form
    form get_values message_editing message_key
    form get_values message_editing package_key
    form get_values message_editing locales
    form get_values message_editing message
    form get_values message_editing return_url

    # Register message via acs-lang
    lang::message::register $locales $package_key $message_key $message

    # Even if the country code is 2 chars, we avoid problems...
    set escaped_locale [ns_urlencode $locales]

    forward $return_url
    
    error $message

}
