<?xml version="1.0"?>
<queryset>
   <rdbms><type>postgresql</type><version>7.1</version></rdbms>

<fullquery name="apm_table">      
      <querytext>

        select   v.version_id, v.package_key, t.pretty_name, v.version_name, v.enabled_p,
                 v.installed_p, v.distribution_uri,
            (select count(*) from apm_package_files f where f.version_id = v.version_id) as n_files,
	     0 as  superseded_p,
             0 as tarball_p
        from    apm_package_versions v, apm_package_types t
        where  t.package_key = v.package_key
        [ad_dimensional_sql $dimensional_list where and]
        [ad_order_by_from_sort_spec $orderby $table_def]

      </querytext>
</fullquery>

<partialquery name="latest">
   <querytext>
     (installed_p = 't' or enabled_p = 't' or not exists (
        select 1 from apm_package_versions v2
        where v2.package_key = v.package_key
          and (v2.installed_p = 't' or v2.enabled_p = 't')
         and apm_package_version__sortable_version_name(v2.version_name) >
             apm_package_version__sortable_version_name(v.version_name)))
   </querytext>
</partialquery>
 
</queryset>
