# explain plan PG

cost premier ligne .. toutes les lignes
l'unité de cout"de page"
rows : nombre de lignes
width: largeru moyenne d'une ligne (en octets)

analyse nom de table

<http://www.dalibo.org/_media/comprendre_explain.pdf>

table pg_statistique ou pg_stats pour voir les statistiques d'une table

les statistiques:

- pourcentages de valeur null
- la largeur moyenne d'une ligne
- nombre valeur distinctes
etc
- valeur les plus frequentes et leur frequence

largeur de ligne: plus c'est petit mieux c'est

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
