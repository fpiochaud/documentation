# Comprendre EXPLAIN

sources: 
- [Comprendre EXPLAIN](https://public.dalibo.com/exports/formation/manuels/modules/j2/j2.handout.pdf) 
- [Explain plan (doc officiel postgres)](https://docs.postgresql.fr/10/using-explain.html)

Création de la tables parent et alimentation (insertion de 1millions de lignes) 

```sql
create table parent (
  id integer primary key, 
  parent text);
insert into parent select i1, md5(random()::text) from generate_series(1,1000000) i1;
```

On calcule les stats de la tables (Comme elle vient d'être remplie)

```sql
analyse parent;
```

Lançons un explain plan sur un select * de la table

```sql
-- explain plan
explain select * from parent;

                              QUERY PLAN                            
-----------------------------------------------------------------
 Seq Scan on parent  (cost=0.00..18334.00 rows=1000000 width=37)
(1 row)
```
- **cost**: Le premier chiffre est le coût pour récupérer la première ligne. Le deuxième chiffre est le coût pour récupérer toutes les lignes. Le coût dépends de la platforme utilisé (citation Kaamelott: L'important c'est la valeur). La pratique est de mesurer en unité de récupération de pages disque ([seq_page_cost](https://docs.postgresql.fr/10/runtime-config-query.html#GUC-SEQ-PAGE-COST))
- **rows** : nombre de lignes estimé sur ce noeud de plan
- **width**: taille moyenne d'une ligne estimée en octets

Création d'une table enfant et alimentation de celle-ci

```sql
create table enfant (
  id integer primary key,
  enfant text,
  parent_id integer references parent (id));
insert into enfant select i1, md5(random()::text), floor(random()*(1-500000)+500000) from generate_series(1,500000)i1;

-- analyse de la table
analyse enfant;

-- explain de la table
explain select * from enfant;

                              QUERY PLAN                            
-----------------------------------------------------------------
Seq Scan on enfant  (cost=0.00..10280.60 rows=560760 width=40)
(1 row)
```

Maintenant, on joint nos deux tables et on regarde son plan d'exécution.

```sql
explain select * from parent
join enfant on parent.id = enfant.parent_id 
order by parent.id;

                              QUERY PLAN                            
-----------------------------------------------------------------
 Merge Join  (cost=72385.10..99423.36 rows=500000 width=82)
   Merge Cond: (parent.id = enfant.parent_id)
   ->  Index Scan using parent_pkey on parent  (cost=0.42..34317.43 rows=1000000 width=37)
   ->  Materialize  (cost=72384.42..74884.42 rows=500000 width=41)
         ->  Sort  (cost=72384.42..73634.42 rows=500000 width=41)
               Sort Key: enfant.parent_id
               ->  Seq Scan on enfant  (cost=0.00..9673.00 rows=500000 width=41)
(7 rows)
```
Petite analyse de l'explain précédent:
- `Merge Join  (cost=72385.10..99423.36 rows=500000 width=82)`: coût total de la requête. \
coût pour récupérer la première ligne 72385.10 \
coût pour récupérer toutes les lignes 99423.36 \
estimation du nombre de lignes ramenées: 500.000 lignes
taille moyenne d'une ligne: 82 octets
  - `Merge Cond: (parent.id = enfant.parent_id)`: \
  Noeud de plan correspondant à la jointure    
  `Index Scan using parent_pkey on parent  (cost=0.42..34317.43 rows=1000000 width=37)` \
  Le planificateur passe par l'indexe de la clé primaire de la table parent \
  `Materialize  (cost=72384.42..74884.42 rows=500000 width=41)`: \
  Le planificateur matrialise la relation interne de la jointure. le parcours d'index ou sort sera fait qu'une seule fois. 
   - `Sort  (cost=72384.42..73634.42 rows=500000 width=41)` \
     Même principe que plus haut \
      - `Sort Key: enfant.parent_id`\ 
        Le sort est fait sur enfant.parent_id alors que dans la requête le sort est sur parent.id. Le planificateur est trouvé que le tri serait plus rapide par les parent_id des enfants
        - `Seq Scan on enfant  (cost=0.00..9673.00 rows=500000 width=41)` \
          Nous sommes sur une lecture sequentiel de la table enfant. 

Rajoutant l'analyse à notre explain et observons.
```sql
explain analyse select * from parent
join enfant on parent.id = enfant.parent_id 
order by parent.id;
                              QUERY PLAN                            
-----------------------------------------------------------------
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
```
Pas de différence par rapport au dernier explain, à une exception faite, une information de la durée actuelle et le nombre de loop fait. On a également la durée de la planification et de l'exécution de la requête.

Et si on ajoutait un index ?
```sql
--Ajout d'index sur la foreign key de enfant (et oui il en faut une)
create index parent_id_idx on enfant (parent_id);
```
Ce n'est pas comme les antibiotiques, ce n'est pas automatique. Ce n'est pas parce qu'il y a une clé étrangère qu'il y a un index dessus.

```sql
explain analyse select * from parent
join enfant on parent.id = enfant.parent_id 
order by parent.id;
                              QUERY PLAN                            
-----------------------------------------------------------------
 Merge Join  (cost=3.15..56225.74 rows=500000 width=82) (actual time=0.011..805.432 rows=500000 loops=1)
   Merge Cond: (parent.id = enfant.parent_id)
   ->  Index Scan using parent_pkey on parent  (cost=0.42..34317.43 rows=1000000 width=37) (actual time=0.004..121.127 rows=500000 loops=1)
   ->  Index Scan using parent_id_idx on enfant  (cost=0.42..31686.80 rows=500000 width=41) (actual time=0.004..489.213 rows=500000 loops=1)
 Planning time: 0.191 ms
 Execution time: 844.028 ms
(6 rows)
```
Aaahh! c'est déjà mieux avec un index !

Maintenant, on change la requête en ajoutant une recherche like.
Voyons voir ce ça donne.

Changeons un peu la requête en ajoutant une recherche like

```sql
explain analyse select * from parent
join enfant on parent.id = enfant.parent_id 
where parent.parent like 'abcd%'
order by parent.id;
                              QUERY PLAN                            
-----------------------------------------------------------------
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
```
On remarque un scan séquenciel sur la colonne parent.
Ajoutons un index sur cette colonne et testons.

```sql
--ajout d'un index sur la colonne parent.parent
create index parent_norm_idx on parent(parent);

explain analyse select * from parent
join enfant on parent.id = enfant.parent_id 
where parent.parent like 'abcd%'
order by parent.id;
                              QUERY PLAN                            
-----------------------------------------------------------------
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
```
On remarque que cela n'améliore pas le plan

```sql
drop index parent_norm_idx;
```

Testons un index text_pattern
```sql
--creation d'index text_pattern
create index parent_textpatern_idx on parent(parent text_pattern_ops);

explain analyse select * from parent
join enfant on parent.id = enfant.parent_id 
where parent.parent like 'abcd%'
order by parent.id;
                              QUERY PLAN                            
-----------------------------------------------------------------
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
```

Modification de la requête
```sql
--modification de la requête
explain analyse select * from parent
join enfant on parent.id = enfant.parent_id 
where parent.parent like '%abcd%'
order by parent.id;
                              QUERY PLAN                            
-----------------------------------------------------------------
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
```

Comment optimiser cette requête.

```sql
--install de la recherche par trigramme
--install del'entension trigramme
create extension pg_trgm;

create index parent_gin_idx on parent using GIN (parent gin_trgm_ops);

explain analyse select * from parent
join enfant on parent.id = enfant.parent_id 
where parent.parent like '%abcd%'
order by parent.id;
                              QUERY PLAN                            
-----------------------------------------------------------------
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
# En vrac

Table pg_statistique ou pg_stats pour voir les statistiques d'une table

Les statistiques:

- pourcentages de valeur null
- la largeur moyenne d'une ligne
- nombre valeur distinctes
etc
- valeur les plus frequentes et leur frequence

largeur de ligne: plus c'est petit mieux c'est. ;-)

cout total:
pour une lecture sequentiel

- lecture de tous les blocs diques de la relation parent
- vérifier chaque ligne de chaque bloc pour filtrer les lignes "invisible" , MVCC (multiversion Cocurency Control )

explain analyse: Attention exécute réellement la requete

- duree réelle d'éxécution
- nombre réel de lignes
- nombre de boucle

explain analyse, buffer
affiche la consommation de shared memory
