<?xml version="1.0"?>
<queryset>

<fullquery name="apm_generate_package_spec.package_version_select">      
      <querytext>
      
        select t.package_key, t.package_uri, t.pretty_name, t.pretty_plural, t.package_type,
	t.initial_install_p, t.singleton_p, v.*
        from   apm_package_versions v, apm_package_types t
        where  v.version_id = :version_id
        and    v.package_key = t.package_key
    
      </querytext>
</fullquery>

 
<fullquery name="apm_generate_package_spec.supported_databases">      
      <querytext>
      
        select distinct db_type
        from apm_package_files
        where db_type is not null
    
      </querytext>
</fullquery>

  
<fullquery name="apm_generate_package_spec.owner_info">      
      <querytext>
      
        select owner_uri, owner_name
        from   apm_package_owners
        where  version_id = :version_id
        order by sort_key
    
      </querytext>
</fullquery>

 
<fullquery name="apm_generate_package_spec.dependency_info">      
      <querytext>
      
        select dependency_type, service_uri, service_version
        from   apm_package_dependencies
        where  version_id = :version_id
        order by dependency_type, service_uri
    
      </querytext>
</fullquery>

 
<fullquery name="apm_generate_package_spec.version_path">      
      <querytext>
      select path, file_type, db_type from apm_package_files where version_id = :version_id order by path
      </querytext>
</fullquery>

 
<fullquery name="apm_generate_package_spec.parameter_info">      
      <querytext>
      
	select parameter_name, description, datatype, section_name, default_value, min_n_values, max_n_values
	  from apm_parameters
	 where package_key = :package_key
    
      </querytext>
</fullquery>

 
</queryset>
