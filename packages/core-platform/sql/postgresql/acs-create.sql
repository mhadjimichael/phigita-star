--
-- packages/acs-kernel/sql/acs-create.sql
--

create table acs_magic_objects (
	name		varchar(100)
			constraint acs_magic_objects_pk primary key,
	object_id	integer not null constraint acs_magic_objects_object_id_fk
                        references acs_objects(object_id)
);

create index acs_mo_object_id_idx on acs_magic_objects (object_id);

comment on table acs_magic_objects is '
 This table allows us to provide semantic names for certain special
 objects like the site-wide organization, and the all users party.
';
create function acs__add_user (integer,varchar,timestamptz,integer,varchar,varchar,varchar,varchar,varchar,char,char,varchar,varchar,varchar,boolean,varchar)
returns integer as '
declare
  user_id                alias for $1;  -- default null    
  object_type            alias for $2;  -- default ''user''
  creation_date          alias for $3;  -- default now()
  creation_user          alias for $4;  -- default null
  creation_ip            alias for $5;  -- default null
  email                  alias for $6;  
  url                    alias for $7;  -- default null
  first_names            alias for $8;  
  last_name              alias for $9;  
  password               alias for $10; 
  salt                   alias for $11; 
  password_question      alias for $12; -- default null
  password_answer        alias for $13; -- default null
  screen_name            alias for $14; -- default null
  email_verified_p       alias for $15; -- default ''t''
  member_state           alias for $16; -- default ''approved''
  v_user_id              users.user_id%TYPE;
  v_rel_id               membership_rels.rel_id%TYPE;
begin
    v_user_id := acs_user__new (user_id, object_type, creation_date,
				creation_user, creation_ip, email,
				url, first_names, last_name, password,
				salt, password_question, password_answer,
				screen_name, email_verified_p,null);
   
    v_rel_id := membership_rel__new (
      null,
      ''membership_rel'',
      acs__magic_object_id(''registered_users''),      
      v_user_id,
      member_state,
      null,
      null);

    PERFORM acs_permission__grant_permission (
      v_user_id,
      v_user_id,
      ''read''
      );

    PERFORM acs_permission__grant_permission (
      v_user_id,
      v_user_id,
      ''write''
      );

    return v_user_id;
   
end;' language 'plpgsql';


-- procedure remove_user
create function acs__remove_user (integer)
returns integer as '
declare
  remove_user__user_id                alias for $1;  
begin
    delete from users
    where user_id = remove_user__user_id;

    return 0; 
end;' language 'plpgsql';


-- function magic_object_id
create function acs__magic_object_id (varchar)
returns integer as '
declare
  magic_object_id__name                   alias for $1;  
  magic_object_id__object_id              acs_objects.object_id%TYPE;
begin
    select object_id
    into magic_object_id__object_id
    from acs_magic_objects
    where name = magic_object_id__name;

    return magic_object_id__object_id;
   
end;' language 'plpgsql';



-- show errors

-- ******************************************************************
-- * Community Core API
-- ******************************************************************

create view registered_users
as
  select p.email, p.url, pe.first_names, pe.last_name, u.*, mr.member_state
  from parties p, persons pe, users u, group_member_map m, membership_rels mr
  where party_id = person_id
  and person_id = user_id
  and u.user_id = m.member_id
  and m.rel_id = mr.rel_id
  and m.group_id = acs__magic_object_id('registered_users')
  and mr.member_state = 'approved'
  and u.email_verified_p = 't';

create view cc_users
as
select o.*, pa.*, pe.*, u.*, mr.member_state, mr.rel_id
from acs_objects o, parties pa, persons pe, users u, group_member_map m, membership_rels mr
where o.object_id = pa.party_id
and pa.party_id = pe.person_id
and pe.person_id = u.user_id
and u.user_id = m.member_id
and m.group_id = acs__magic_object_id('registered_users')
and m.rel_id = mr.rel_id
and m.container_id = m.group_id;

-----------------------------------
-- Community Core Initialization --
-----------------------------------

-- The very first thing we must do is create the security_context_root
-- object.

create function inline_0 ()
returns integer as '
declare
  root_id integer;
begin
  
  root_id := acs_object__new (
    0,
    ''acs_object'',
    now(),
    null,
    null,
    null
    );

  insert into acs_magic_objects
   (name, object_id)
  values
   (''security_context_root'', 0);


  return root_id;

end;' language 'plpgsql';

select inline_0 ();

drop function inline_0 ();


-- show errors

begin;

 --------------------------------------------------------------
 -- Some privilege that will be fundamental to all objects. --
 --------------------------------------------------------------

 select acs_privilege__create_privilege('read', null, null);
 select acs_privilege__create_privilege('write', null, null);
 select acs_privilege__create_privilege('create', null, null);
 select acs_privilege__create_privilege('delete', null, null);
 select acs_privilege__create_privilege('admin', null, null);

 ---------------------------------------------------------
 -- Administrators can read, write, create, and delete. -- 
 ---------------------------------------------------------

 -- temporarily drop this trigger to avoid a data-change violation 
 -- on acs_privilege_hierarchy_index while updating the child privileges.

 drop trigger acs_priv_hier_ins_del_tr on acs_privilege_hierarchy;

 select acs_privilege__add_child('admin', 'read');
 select acs_privilege__add_child('admin', 'write');
 select acs_privilege__add_child('admin', 'create');

 -- re-enable the trigger before the last insert to force the 
 -- acs_privilege_hierarchy_index table to be updated.

 create trigger acs_priv_hier_ins_del_tr after insert or delete
 on acs_privilege_hierarchy for each row
 execute procedure acs_priv_hier_ins_del_tr ();

 select acs_privilege__add_child('admin', 'delete');

end;


-- show errors

create function inline_2 ()
returns integer as '
declare
  v_object_id integer;
begin

 insert into acs_objects
  (object_id, object_type)
 values
  (-1, ''party'');

 insert into parties
  (party_id)
 values
  (-1);

 insert into acs_magic_objects
  (name, object_id)
 values
  (''the_public'', -1);

  return 0;
end;' language 'plpgsql';

select inline_2 ();

drop function inline_2 ();


create function inline_3 ()
returns integer as '
declare
  group_id integer;
begin

  group_id := acs_group__new (
    -2,
    ''group'',
    now(),
    null,
    null,
    null,
    null,
    ''Registered Users'',
    null,
    null
  );

 insert into acs_magic_objects
  (name, object_id)
 values
  (''registered_users'', -2);

  return 0;
end;' language 'plpgsql';

select inline_3 ();

drop function inline_3 ();

 
select acs_object__new (
    -3,
    'acs_object',
    now(),
    null,
    null,
    null
  );

 insert into acs_magic_objects
  (name, object_id)
 values
  ('default_context', -3);
                  
                  
-- show errors


-- Moved from acs-create-2.sql
--
-- This code sets up additional root concepts, involving the
-- privacy control of personal information. For now, this sets
-- up an extremely simple concept of read_private_data that is NOT
-- derived from read, but rather from admin.
--

select acs_privilege__create_privilege('read_private_data');
select acs_privilege__add_child('admin','read_private_data');
