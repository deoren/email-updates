-- $Id$
-- $HeadURL$

-- Purpose: Misc SQL snippets that acts as a "cheatsheet" for me
--          since I'm a SQL newbie

-- Crude, but allows me to trim the last handful of reported updates
-- from the table so I rerun the script without those updates
-- already being listed in the table. Should be replaced with one
-- that matches on "Today's" date.
delete from reported_updates where id in (31, 32, 33, 34, 35, 36, 37);
