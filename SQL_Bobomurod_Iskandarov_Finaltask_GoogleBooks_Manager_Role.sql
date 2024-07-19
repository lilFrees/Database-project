CREATE ROLE manager_readonly WITH LOGIN PASSWORD 'qwerty';

GRANT USAGE ON SCHEMA denormalized TO manager_readonly;

GRANT SELECT ON ALL TABLES IN SCHEMA denormalized TO manager_readonly;

ALTER DEFAULT PRIVILEGES IN SCHEMA denormalized
GRANT SELECT ON TABLES TO manager_readonly;

REVOKE ALL ON SCHEMA denormalized FROM PUBLIC;

REVOKE CREATE ON SCHEMA denormalized FROM manager_readonly;
REVOKE USAGE ON ALL SEQUENCES IN SCHEMA denormalized FROM manager_readonly;

SELECT grantee, privilege_type, table_schema, table_name 
FROM information_schema.table_privileges 
WHERE grantee = 'manager_readonly' 
  AND table_schema = 'denormalized';