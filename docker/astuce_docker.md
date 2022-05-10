# Astuce Docker

## Copier un volume docker vers un autre volume

Créer un nouveau volume vide
``` bash
docker volume create volume_save
```
On crée un conternaire ephemere (il se supprime après exécution) pour copier les données du volume du container 1 vers le volume nouvellement créé.

``` bash
docker run --rm --volumes-from my_container -v volume_save:/target alpine sh -c "cp -rp /var/lib/postgresql/data/. /target"
```
`--rm` : supprime le container après exécution \
`--volumes-from` : on démarre notre container avec les volumes d'un autre container\
`-v` : on mappe notre volume_save sur le point de montage /target\
`alpine` : on utilise une image légère pour faire la copie\
`sh -c "cp -rp /var/lib/postgresql/data/. /target"` : On fait une copie de toutes l'arborescence avec conservation des droits

lien utile: \
https://www.youtube.com/watch?v=H35x08CoJLc&ab_channel=ManuelCastellin \
https://docs.docker.com/storage/volumes/
