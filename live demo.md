# Plan

## pgadmin4

## recherche full text sous postgresq

## Comprendre EXPLAIN

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
insert into enfant select i1, md5(random()::text), floor(random()*(1-500000)+500000) from generate_series(1,2000000)i1;

analyse enfant;
explain select * from enfant;

                           QUERY PLAN                            
-----------------------------------------------------------------
 Seq Scan on enfant  (cost=0.00..41122.40 rows=2243040 width=40)
(1 row)

explain select * from parent
join enfant on parent.id = enfant.parent_id 
order by parent.id;

explain analyse select * from parent
join enfant on parent.id = enfant.parent_id 
order by parent.id;

select parent.parent 
from parent left join enfant on (parent.id = enfant.parent_id) 
group by parent.parent having count(*) =10;


create index parent_id_idx on enfant (parent_id);


rafraichir les statistiques
vacuum analyse users;

accélérer une requete like '%lk%'

Ma recherche
explain select id,name from users where name like 'Fran%';
so=# explain analyse select id,name from users where name like 'Fran%';
                                                  QUERY PLAN                                                  
--------------------------------------------------------------------------------------------------------------
 Seq Scan on users  (cost=0.00..189377.11 rows=705 width=15) (actual time=0.227..1382.385 rows=14820 loops=1)
   Filter: (name ~~ 'Fran%'::text)
   Rows Removed by Filter: 7235919
 Planning time: 0.070 ms
 Execution time: 1383.699 ms
(5 rows)

Time: 1384,433 ms

so=# explain analyse select id,name from users where name like '%ran%';
                                                   QUERY PLAN                                                    
-----------------------------------------------------------------------------------------------------------------
 Seq Scan on users  (cost=0.00..189377.11 rows=142390 width=15) (actual time=0.064..1378.019 rows=96617 loops=1)
   Filter: (name ~~ '%ran%'::text)
   Rows Removed by Filter: 7154122
 Planning time: 0.075 ms
 Execution time: 1383.301 ms
(5 rows)

Time: 1384,474 ms

create index name_norm_idx on (name);

explain analyse select id,name from users where name like '%ran%io%';
                                                 QUERY PLAN                                                 
------------------------------------------------------------------------------------------------------------
 Seq Scan on users  (cost=0.00..189382.24 rows=705 width=15) (actual time=2.347..1437.528 rows=617 loops=1)
   Filter: (name ~~ '%ran%io%'::text)
   Rows Removed by Filter: 7250122
 Planning time: 0.195 ms
 Execution time: 1437.725 ms
(5 rows)

select id,name from users where name = 'Franck Piochaud';
   id    |      name       
---------+-----------------
 6798003 | Franck Piochaud
(1 row)

Time: 0,835 ms

create index name_trgm_idx on users using GIN (name gin_trgm_ops);


installer l'extension pg_trgm
create extension pg_trgm;





