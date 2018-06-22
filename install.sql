-- -*- mode: sql; sql-product: postgres -*-

-- Create a login role for ambassador
CREATE USER ambassador;

-- Use this if your deployment uses passwords rather than peer authentication:
-- ALTER ROLE mastodon_ambassador WITH PASSWORD 'something secret, hopefully';
--
-- Note that PostgreSQL supports setting “encrypted” (hashed) passwords,
-- which is a better option if the password must be stored in some configuration
-- management tool.


-- Now, create the view that ambassador actually uses
CREATE VIEW public_toots AS
  SELECT *
    FROM statuses
   WHERE visibility = 0
;

-- Change 13104 to your ambassador's account ID
CREATE VIEW blocks_ambassador AS
  SELECT account_id
    FROM blocks
    WHERE target_account_id = 13104;

-- Make sure the role doesn't have access to anything undesireable
REVOKE ALL FROM ambassador;

-- Let ambassador select from the view
GRANT SELECT ON public_toots TO ambassador;
GRANT SELECT ON blocks_ambassador TO ambassador;
