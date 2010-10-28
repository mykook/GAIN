/* this is either researchers.out generated by srrecs_researchers.pig,
   or just reddit_linkvote.dump, generated by
psql -F"\t" -A -t -d newreddit -U ri -h $VOTEDBHOST \
     -c "\\copy (select r.rel_id, 'vote_account_link',
                        r.thing1_id, r.thing2_id, r.name, extract(epoch from r.date)
                   from reddit_rel_vote_account_link r
                   where date > now() - interval '1 week'
                ) to 'reddit_linkvote.dump'"
*/
linkvote_dump = LOAD 'researchers.out'
    AS (rel_id, vote_account_link_label, account_id, link_id, dir:int, timestamp);

/* remove 0 votes */
linkvote_votes = FILTER linkvote_dump BY (dir == -1 or dir == 1);

/*
time psql -F"\t" -A -t -d newreddit -U ri -h $LINKDBHOST \
     -c "\\copy (select d.thing_id, 'data', 'link',
                        d.key, d.value
                   from reddit_data_link d, reddit_thing_link t
                  where t.date > now() - interval '1 week'
                        and t.thing_id = d.thing_id
                        and d.key = 'sr_id') to 'reddit_data_link.dump'"
*/
linkdata_dump = LOAD 'reddit_data_link.dump'
    AS (link_id, data_label, link_label, srid_label, sr_id);
links_srids = FOREACH linkdata_dump GENERATE link_id, sr_id;

links_srids_votes = JOIN linkvote_votes by link_id, links_srids by link_id PARALLEL 2;
links_srids_votes = FOREACH links_srids_votes GENERATE account_id, links_srids::link_id AS link_id, links_srids::sr_id as sr_id, dir;

STORE links_srids_votes INTO 'links_srids_votes.out' using PigStorage('\t');