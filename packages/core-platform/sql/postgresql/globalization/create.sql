-- packages/acs-reference/sql/postgresql/acs-reference-create.sql
--
-- @author jon@jongriffin.com
-- @creation-date 2001-07-16
--
-- @cvs-id $Id: acs-reference-create.sql,v 1.7 2001/09/02 17:06:29 donb Exp $


\i globalization/ad-locales-create.sql
\i globalization/message-catalog-create.sql 


-- Create the basic object type used to represent a reference database
select acs_object_type__create_type (
        'acs_reference_repository',
        'ACS Reference Repository',
        'ACS Reference Repositories', 
        'acs_object',
        'acs_reference_repositories',
        'repository_id',
        null,
        'f',
	null,
	'acs_object__default_name'
);

-- A table to store metadata for each reference database
-- add functions to do exports and imports to selected tables.

create table acs_reference_repositories (
    repository_id	integer
			constraint arr_repository_id_fk references acs_objects (object_id)
			constraint arr_repository_id_pk primary key,
    -- what is the table name we are monitoring
    table_name		varchar(100)  
			constraint arr_table_name_nn not null
			constraint arr_table_name_uq unique,
    -- is this external or internal data
    internal_data_p     boolean,
    -- Does this source include pl/sql package?
    package_name	varchar(100)
			constraint arr_package_name_uq unique,
    -- last updated
    last_update		timestamp,
    -- where is this data from
    source		varchar(1000),
    source_url		varchar(255),
    -- should default to today
    effective_date	timestamp, -- default sysdate
    expiry_date		timestamp,
    -- a text field to hold the maintainer
    maintainer_id	integer
			constraint arr_maintainer_id_fk references persons(person_id),
    -- this could be ancillary docs, pdf's etc
    -- needs to be fixed for PG
    -- DRB: needs to use Content Repository for both PG and Oracle, no???
    lob 		integer
);

-- API


-- default for Oracle

create function acs_reference__new (integer,varchar,boolean,varchar,timestamp,
varchar,varchar,timestamp,timestamp,integer,integer,varchar,varchar,
integer,varchar,integer)
returns integer as '
declare
    p_repository_id   alias for $1; -- default null
    p_table_name      alias for $2; -- 
    p_internal_data_p alias for $3; -- default "f"
    p_package_name    alias for $4; -- default null
    p_last_update     alias for $5; -- default sysdate
    p_source          alias for $6; -- default null
    p_source_url      alias for $7; -- default null
    p_effective_date  alias for $8; -- default sysdate
    p_expiry_date     alias for $9; -- default null
    p_maintainer_id   alias for $10; -- default null
    p_notes           alias for $11; -- default null (not Oracle empty_blob())
-- I really see no need for these as parameters
--    creation_date   alias for $12; -- default sysdate
    p_first_names     alias for $12; -- default null
    p_last_name      alias for $13; -- default null
    p_creation_ip     alias for $14; -- default null
    p_object_type     alias for $15; -- default "acs_reference_repository"
    p_creation_user   alias for $16; -- default null
    v_repository_id acs_reference_repositories.repository_id%TYPE;
    v_object_type   acs_objects.object_type%TYPE;
    v_maintainer_id persons.person_id%TYPE;
begin
    if p_object_type is null then
        v_object_type := ''acs_reference_repository'';
    else
        v_object_type := p_object_type;
    end if;

    v_repository_id := acs_object__new (
         p_repository_id,    
         v_object_type,
         now(),
         p_creation_user,
         p_creation_ip,
         null
    );

    -- This logic is not correct as the maintainer could already exist
    -- The way around this is a little clunky as you can search persons
    -- then pick an existing person or add a new one, to many screens!
    -- I really doubt the need for person anyway.
    --
    -- It probably needs to just be a UI function and pass
    -- in the value for maintainer.
    --
    -- IN OTHER WORDS
    -- Guaranteed to probably break in the future if you depend on
    -- first_names and last_name to still exist as a param
    -- This needs to be updated in the Oracle version also
    -- NEEDS TO BE FIXED - jag

    if p_first_names is not null and p_last_name is not null and p_maintainer_id is null then
        v_maintainer_id := person__new (null, ''person'', now(), null, null, null, null,
	                                p_first_names, p_last_name, null);
	else if p_maintainer_id is not null then
           v_maintainer_id := p_maintainer_id;
        else 
	    v_maintainer_id := null;
	end if;
    end if;

    insert into acs_reference_repositories
        (repository_id,table_name,internal_data_p,
         last_update,package_name,source, 
         source_url,effective_date,expiry_date,
         maintainer_id,lob)
    values 
        (v_repository_id, p_table_name, p_internal_data_p,
         p_last_update, p_package_name, p_source, p_source_url,
         p_effective_date, p_expiry_date, v_maintainer_id, p_notes);

    return v_repository_id;    
end;
' language 'plpgsql';

-- made initially for PG 
create function acs_reference__new (varchar,timestamp,
varchar,varchar,timestamp)
returns integer as '
declare
    p_table_name      alias for $1; -- 
    p_last_update     alias for $2; -- default sysdate
    p_source          alias for $3; -- default null
    p_source_url      alias for $4; -- default null
    p_effective_date  alias for $5; -- default sysdate
    v_repository_id acs_reference_repositories.repository_id%TYPE;
begin
    return acs_reference__new(null, p_table_name, ''f'', null, null, p_source, p_source_url,
                              p_effective_date, null, null, null, null, null, null,
                              ''acs_reference_repository'', null);
end;
' language 'plpgsql';

create function acs_reference__delete (integer)
returns integer as '
declare
    p_repository_id alias for $1;
    v_maintainer_id		acs_objects.object_id%TYPE;
begin
    select maintainer_id into v_maintainer_id
    from   acs_reference_repositories
    where  repository_id = p_repository_id;

    delete from acs_reference_repositories
    where repository_id = p_repository_id;

    perform acs_object__delete(p_repository_id);
    return 0;
end;
' language 'plpgsql';

create function acs_reference__is_expired_p (integer)
returns char as '
declare
    repository_id alias for $1;
begin
    select expiry_date into v_expiry_date
    from   acs_reference_repositories
    where  repository_id = is_expired_p.repository_id;

    if coalesce(v_expiry_date,now()+1) < now() then
        return ''t'';
    else
        return ''f'';
    end if;
end;
' language 'plpgsql';

--\i ref-languages-create.sql
--\i ref-countries-create.sql
--\i ref-timezones-create.sql
