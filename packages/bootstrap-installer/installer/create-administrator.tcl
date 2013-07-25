ad_page_contract {

    Prompts the user to enter information used to create an administrator.
    @author Jon Salz (jsalz@arsdigita.com)
    @author Bryan Quinn (bquinn@arsdigita.com)
    @cvs-id $Id: create-administrator.tcl,v 1.1.1.1 2002/11/22 09:47:31 nkd Exp $

} {}

if { ![install_good_data_model_p] } {
    install_return 200 "Data Model Not Installed" "

It appears that the data model is not yet installed. Please <a href=\"index\">go back
to the beginning and try again</a>.

"
    return
}

if { [db_0or1row user_exists "select email from cc_users where rownum = 1"] } {
    install_return 200 "Administrator Already Created" "

The site-wide administrator ($email) has already been created. Click the <i>Next</i>
button to set information about your site.

<center><form action=site-info>
[ad_export_vars -form email]
<input type=submit value=\"Next ->\">
</form>
</center>
"
    return
}

set body "

<body onload=\"javascript:document.adminform.email.focus();\">

We'll need to create a site-wide administrator for your server (like the root
user in UNIX). Please type in the email address, first and last name, and password
for this user.

<form name=adminform action=create-administrator-2>
<blockquote>
<table>
<tr>
  <th align=right>Email:</th>
  <td><input name=email size=20></td>
</tr>
<tr>
  <th align=right>First Name:</th>
  <td><input name=first_names size=20></td>
</tr>
<tr>
  <th align=right>Last Name:</th>
  <td><input name=last_name size=20></td>
</tr>
<tr>
  <th align=right>Password:</th>
  <td><input type=password name=password size=12></td>
</tr>
<tr>
  <th align=right>Password (again):</th>
  <td><input type=password name=password_confirmation size=12></td>
</tr>
<tr valign=baseline>
  <th align=right>Password Question:</th>
  <td><select name=password_question>
<option>What is your mother's maiden name?
<option>Is it better to be loved or feared?
<option>How much wood could a woodchuck chuck?
<option>Hello - is there anybody out there?
<option>Hvad skal vi have til frokost?
</select><br>(To be asked if you forget your password.)
</td>
</tr>
<tr>
  <th align=right>Password Answer:</th>
  <td><input name=password_answer size=30></td>
</tr>

<tr><td colspan=2 align=center><br><input type=submit value=\"Create User ->\"></td></tr>
</form>
</table>
</blockquote>
</body>
"

install_return 200 "Create Administrator" $body
