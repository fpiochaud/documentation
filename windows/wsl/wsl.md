# wsl 2

## Pré-requis

Il faut être en windows 10 version 2004 minimum

## Installation

Une fois la bonne version de windows installé, lancer la commande

```bash
wsl --install # un redémarrage du poste sera peut être nécessaire
```

En théorie, elle doit installer une distribution Ubuntu par default
si ce n'est pas le cas faire la commande suivante

```bash
wsl --install -d Ubuntu
```

## Changement de version de wsl

Si plusieurs distributions installées sur le poste,
on peut definir une distribution par défaut avec la commande suivante

```bash
wsl --set-default Ubuntu
```

Pour lister les distributions avec leur versions
wsl --list -v

Si les version sont en version 1 pour les passer en version 2
faire la commande suivante

```bash
wsl --set-default-version 2
```
## Changement du user par défaut

```bash
ubuntu config --default-user my_user
```

## Déplacement de la distribution sur un autre emplacement

```bash
# on exporte la ditribution dans fichier tar
wsl --export Ubuntu G:/Ubuntu_wsl.tar
# on supprime la distribution
wsl --unregister Ubuntu
# on réimporte à la nouvelle destination
wsl --import Ubuntu G:\WSL G:\Ubuntu_wsl.tar
# on remet l'utilisateur par défaut
Ubuntu config --default-user franck
```

## Limitation des ressources 
Créer un fichier dans : C:\Users\my_user\.wslvonfig

```bash
[wsl2]
memory=3GB   # Limits VM memory in WSL 2 up to 3GB
processors=4 # Makes the WSL 2 VM use two virtual processors
[automount]
options = "metadata"
```