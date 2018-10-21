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
DROP VIEW IF EXISTS public_toots;
CREATE VIEW public_toots AS
  SELECT 
   statuses.id, statuses.reblog_of_id, statuses.account_id,
   statuses.updated_at, status_stats.favourites_count
    FROM statuses
    LEFT OUTER JOIN status_stats
     ON statuses.id = status_stats.status_id
   WHERE statuses.visibility = 0
    AND statuses.updated_at > NOW() - INTERVAL '30 days'
    AND statuses.local IS TRUE
    AND NOT EXISTS (
     SELECT 1 FROM blocks
      WHERE statuses.account_id = blocks.account_id
      AND blocks.target_account_id = 13104  -- Change 13104 to your ambassador's account ID
     )
;

-- performance helper
CREATE INDEX index_status_stats_on_favourites_count ON status_stats (favourites_count);

-- Make sure the role doesn't have access to anything undesireable
REVOKE ALL FROM ambassador;

-- Let ambassador select from the view
GRANT SELECT ON public_toots TO ambassador;
