## Comprendre EXPLAIN
source: [Comprendre EXPLAIN](http://www.dalibo.org/_media/comprendre_explain.pdf)

Creation de deux tables parent et enfant et alimentation

```sql
create table parent (
  id integer primary key, 
  parent text);
insert into parent select i1, md5(random()::text) from generate_series(1,1000000) i1;

analyse parent;
explain select * from parent;

                           QUERY PLAN                            
-----------------------------------------------------------------
 Seq Scan on parent  (cost=0.00..18334.00 rows=1000000 width=37)
(1 row)

create table enfant (
  id integer primary key,
  enfant text,
  parent_id integer references parent (id));
insert into enfant select i1, md5(random()::text), floor(random()*(1-500000)+500000) from generate_series(1,500000)i1;

analyse enfant;
explain select * from enfant;

                           QUERY PLAN                            
-----------------------------------------------------------------
 Seq Scan on enfant  (cost=0.00..41122.40 rows=2243040 width=40)
(1 row)

explain select * from parent
join enfant on parent.id = enfant.parent_id 
order by parent.id;
                                        QUERY PLAN                                         
-------------------------------------------------------------------------------------------
 Merge Join  (cost=72385.10..99423.36 rows=500000 width=82)
   Merge Cond: (parent.id = enfant.parent_id)
   ->  Index Scan using parent_pkey on parent  (cost=0.42..34317.43 rows=1000000 width=37)
   ->  Materialize  (cost=72384.42..74884.42 rows=500000 width=41)
         ->  Sort  (cost=72384.42..73634.42 rows=500000 width=41)
               Sort Key: enfant.parent_id
               ->  Seq Scan on enfant  (cost=0.00..9673.00 rows=500000 width=41)
(7 rows)

explain analyse select * from parent
join enfant on parent.id = enfant.parent_id 
order by parent.id;
                                                                 QUERY PLAN                                                                 
--------------------------------------------------------------------------------------------------------------------------------------------
 Merge Join  (cost=72385.10..99423.36 rows=500000 width=82) (actual time=305.680..878.392 rows=500000 loops=1)
   Merge Cond: (parent.id = enfant.parent_id)
   ->  Index Scan using parent_pkey on parent  (cost=0.42..34317.43 rows=1000000 width=37) (actual time=0.008..107.787 rows=500000 loops=1)
   ->  Materialize  (cost=72384.42..74884.42 rows=500000 width=41) (actual time=305.666..583.434 rows=500000 loops=1)
         ->  Sort  (cost=72384.42..73634.42 rows=500000 width=41) (actual time=305.663..514.223 rows=500000 loops=1)
               Sort Key: enfant.parent_id
               Sort Method: external merge  Disk: 26320kB
               ->  Seq Scan on enfant  (cost=0.00..9673.00 rows=500000 width=41) (actual time=0.009..61.778 rows=500000 loops=1)
 Planning time: 0.179 ms
 Execution time: 924.981 ms
(10 rows)

create index parent_id_idx on enfant (parent_id);

explain analyse select * from parent
join enfant on parent.id = enfant.parent_id 
order by parent.id;
                                                                 QUERY PLAN                                                                  
---------------------------------------------------------------------------------------------------------------------------------------------
 Merge Join  (cost=3.15..56225.74 rows=500000 width=82) (actual time=0.011..805.432 rows=500000 loops=1)
   Merge Cond: (parent.id = enfant.parent_id)
   ->  Index Scan using parent_pkey on parent  (cost=0.42..34317.43 rows=1000000 width=37) (actual time=0.004..121.127 rows=500000 loops=1)
   ->  Index Scan using parent_id_idx on enfant  (cost=0.42..31686.80 rows=500000 width=41) (actual time=0.004..489.213 rows=500000 loops=1)
 Planning time: 0.191 ms
 Execution time: 844.028 ms
(6 rows)


--changement de la requete en ajoutant une recherche like
explain analyse select * from parent
join enfant on parent.id = enfant.parent_id 
where parent.parent like 'abcd%'
order by parent.id;
                                                         QUERY PLAN                                                          
-----------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=32385.16..32385.29 rows=50 width=82) (actual time=180.327..180.328 rows=3 loops=1)
   Sort Key: parent.id
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=20835.25..32383.75 rows=50 width=82) (actual time=103.183..180.313 rows=3 loops=1)
         Hash Cond: (enfant.parent_id = parent.id)
         ->  Seq Scan on enfant  (cost=0.00..9673.00 rows=500000 width=41) (actual time=0.007..39.229 rows=500000 loops=1)
         ->  Hash  (cost=20834.00..20834.00 rows=100 width=37) (actual time=101.682..101.682 rows=14 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 9kB
               ->  Seq Scan on parent  (cost=0.00..20834.00 rows=100 width=37) (actual time=18.686..101.650 rows=14 loops=1)
                     Filter: (parent ~~ 'abcd%'::text)
                     Rows Removed by Filter: 999986
 Planning time: 0.136 ms
 Execution time: 180.349 ms
(13 rows)


--ajout d'un index sur la colonne parent.parent
create index parent_norm_idx on parent(parent);

explain analyse select * from parent
join enfant on parent.id = enfant.parent_id 
where parent.parent like 'abcd%'
order by parent.id;
                                                         QUERY PLAN                                                         
----------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=32385.16..32385.29 rows=50 width=82) (actual time=166.312..166.313 rows=3 loops=1)
   Sort Key: parent.id
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=20835.25..32383.75 rows=50 width=82) (actual time=88.954..166.297 rows=3 loops=1)
         Hash Cond: (enfant.parent_id = parent.id)
         ->  Seq Scan on enfant  (cost=0.00..9673.00 rows=500000 width=41) (actual time=0.006..39.534 rows=500000 loops=1)
         ->  Hash  (cost=20834.00..20834.00 rows=100 width=37) (actual time=87.487..87.487 rows=14 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 9kB
               ->  Seq Scan on parent  (cost=0.00..20834.00 rows=100 width=37) (actual time=12.735..87.457 rows=14 loops=1)
                     Filter: (parent ~~ 'abcd%'::text)
                     Rows Removed by Filter: 999986
 Planning time: 0.291 ms
 Execution time: 166.334 ms
(13 rows)


drop index parent_norm_idx;

--creation d'index text_patern
create index parent_textpatern_idx on parent(parent text_pattern_ops);

explain analyse select * from parent
join enfant on parent.id = enfant.parent_id 
where parent.parent like 'abcd%'
order by parent.id;
                                                                    QUERY PLAN                                                                    
--------------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=11606.36..11606.49 rows=50 width=82) (actual time=90.681..90.681 rows=3 loops=1)
   Sort Key: parent.id
   Sort Method: quicksort  Memory: 25kB
   ->  Hash Join  (cost=56.45..11604.95 rows=50 width=82) (actual time=1.897..90.667 rows=3 loops=1)
         Hash Cond: (enfant.parent_id = parent.id)
         ->  Seq Scan on enfant  (cost=0.00..9673.00 rows=500000 width=41) (actual time=0.008..47.307 rows=500000 loops=1)
         ->  Hash  (cost=55.20..55.20 rows=100 width=37) (actual time=0.060..0.060 rows=14 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 9kB
               ->  Bitmap Heap Scan on parent  (cost=4.58..55.20 rows=100 width=37) (actual time=0.031..0.057 rows=14 loops=1)
                     Filter: (parent ~~ 'abcd%'::text)
                     Heap Blocks: exact=14
                     ->  Bitmap Index Scan on parent_textpatern_idx  (cost=0.00..4.55 rows=13 width=0) (actual time=0.025..0.025 rows=14 loops=1)
                           Index Cond: ((parent ~>=~ 'abcd'::text) AND (parent ~<~ 'abce'::text))
 Planning time: 0.263 ms
 Execution time: 90.709 ms
(15 rows)

--modification de la requête
explain analyse select * from parent
join enfant on parent.id = enfant.parent_id 
where parent.parent like '%abcd%'
order by parent.id;
                                                         QUERY PLAN                                                          
-----------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=32385.16..32385.29 rows=50 width=82) (actual time=288.069..288.094 rows=217 loops=1)
   Sort Key: parent.id
   Sort Method: quicksort  Memory: 55kB
   ->  Hash Join  (cost=20835.25..32383.75 rows=50 width=82) (actual time=194.291..287.888 rows=217 loops=1)
         Hash Cond: (enfant.parent_id = parent.id)
         ->  Seq Scan on enfant  (cost=0.00..9673.00 rows=500000 width=41) (actual time=0.007..47.339 rows=500000 loops=1)
         ->  Hash  (cost=20834.00..20834.00 rows=100 width=37) (actual time=193.714..193.714 rows=459 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 39kB
               ->  Seq Scan on parent  (cost=0.00..20834.00 rows=100 width=37) (actual time=0.031..193.411 rows=459 loops=1)
                     Filter: (parent ~~ '%abcd%'::text)
                     Rows Removed by Filter: 999541
 Planning time: 0.169 ms
 Execution time: 288.129 ms
(13 rows)

--install de la recherche par trigramme
--install del'entension trigramme
create extension pg_trgm;

create index parent_gin_idx on parent using GIN (parent gin_trgm_ops);

explain analyse select * from parent
join enfant on parent.id = enfant.parent_id 
where parent.parent like '%abcd%'
order by parent.id;
                                                                  QUERY PLAN                                                                  
----------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=11948.32..11948.45 rows=50 width=82) (actual time=92.068..92.087 rows=217 loops=1)
   Sort Key: parent.id
   Sort Method: quicksort  Memory: 55kB
   ->  Hash Join  (cost=398.41..11946.91 rows=50 width=82) (actual time=3.026..91.929 rows=217 loops=1)
         Hash Cond: (enfant.parent_id = parent.id)
         ->  Seq Scan on enfant  (cost=0.00..9673.00 rows=500000 width=41) (actual time=0.016..45.692 rows=500000 loops=1)
         ->  Hash  (cost=397.16..397.16 rows=100 width=37) (actual time=2.422..2.422 rows=459 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 39kB
               ->  Bitmap Heap Scan on parent  (cost=28.77..397.16 rows=100 width=37) (actual time=0.731..2.352 rows=459 loops=1)
                     Recheck Cond: (parent ~~ '%abcd%'::text)
                     Rows Removed by Index Recheck: 41
                     Heap Blocks: exact=484
                     ->  Bitmap Index Scan on parent_gin_idx  (cost=0.00..28.75 rows=100 width=0) (actual time=0.677..0.677 rows=500 loops=1)
                           Index Cond: (parent ~~ '%abcd%'::text)
 Planning time: 0.316 ms
 Execution time: 92.136 ms
(16 rows)

```