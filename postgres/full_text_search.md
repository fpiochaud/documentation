# La recherche full text search sous postgres

source: [PG Day France 2017 : Adrien Nayrat - Comment fonctionne la recherche plein texte ?](https://www.youtube.com/watch?v=9S5dBqMbw8A&t=1326s)

Lexème les mots utiles et seulement leur racine

## Liste triée de lexèmes tsvector

```bash
select to_tsvector('french','Comment fonctionne la recherche plein texte');
                       to_tsvector                        
----------------------------------------------------------
 'comment':1 'fonction':2 'plein':5 'recherch':4 'text':6
(1 row)
```

parser \
but: identifier des tokens \
exemple: \
word: mot comportant des lettres \
int: entier signé \
url: lien \
email: adress mail \
tag: balise xml \
blank: espace

```bash
#pour voir la listes des tokens détectés par défaut
\dFp+
```

fonction de débug pour identifier les tokens identifiés sur une chaine

```bash
select alias,description,token from ts_debug('DTSI Etude axi@gouv.nc http://www.monportailrh.nc');

   alias   |   description   |        token        
-----------+-----------------+---------------------
 asciiword | Word, all ASCII | DTSI
 blank     | Space symbols   |  
 asciiword | Word, all ASCII | Etude
 blank     | Space symbols   |  
 email     | Email address   | axi@gouv.nc
 blank     | Space symbols   |  
 protocol  | Protocol head   | http://
 host      | Host            | www.monportailrh.nc
(8 rows)
```

les dictionnaires  \
succesion de filtres permettant d'obtenir un lexeme \
supprimer la casse \
retirer les stops words \
remplacer des synonymes \

pour résumé le FTS (full text search) c'est \
un parser \
plusieurs dictionnaires \
mapping: applique les dictionnaire en fonction des caégories de token

mapping par défaut \

```bash
\dF+ english
Text search configuration "pg_catalog.english"
Parser: "pg_catalog.default"
      Token      | Dictionaries 
-----------------+--------------
 asciihword      | english_stem
 asciiword       | english_stem
 email           | simple
 file            | simple
 float           | simple
 host            | simple
 hword           | english_stem
 hword_asciipart | english_stem
 hword_numpart   | simple
 hword_part      | english_stem
 int             | simple
 numhword        | simple
 numword         | simple
 sfloat          | simple
 uint            | simple
 url             | simple
 url_path        | simple
 version         | simple
 word            | english_stem
```

les opérateurs \
comment interroger les tsvector? \
type tsquery \
opérateur @@ \
fonction to_tsquery, plainto_tsquery et phraseto_tsquery

type tsquery \

- comprend les lexemes recherchés qui peuvent etre combinés avec les opérateur suivant
  - & (and)
  - | (or)
  - ! (not)
  - l'opérateur de recherche de phrase (depuis la 9.6): <-> (followed by)

exemple: \
une recherche dans google de type chat and chien se traduit par:

```bash
select 'chat & chient'::tsquery;
      tsquery      
-------------------
 'chat' & 'chient'
(1 row)

Time: 51,638 ms

 

 opération @@
 permet d'interroger un tsvector
 select to_tsvector('chat chien') @@ 'chat'::tsquery;
 ?column? 
----------
 t
(1 row)
```

exemple

```bash
select to_tsvector('french','cheval poney') @@ 'cheval'::tsquery;
true
select to_tsvector('french', 'cheval poney') @@ 'chevaux'::tsquery;
false

select to_tsvector('french','chevaux');
```

on compare un mot à lexeme
on devrait comparer deux lexeme

```bash
select to_tsvector('french', 'cheval poney') @@ to_tsquery('french','chevaux');
```

plainti_tsquery \
convertir une chaine de texte en tsquery \
phraseto_tsquery permet la recherche de phrase \

```bash
select plainto_tsquery('french','chevaux poney');
  plainto_tsquery   
--------------------
 'cheval' & 'poney'
(1 row)
```

phraseto_tsquery permet la recherche de phrase
`select plainto_tsquery('french', 'chevaux poney');`

performance ?
tests pour la base stackoverflow

```bash
\dt+ posts
```
