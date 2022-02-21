# Commandes de base

## Initialiser un repository local

```bash
git init
git commit -m "first commit"
# sur github uniquement les branches master on été renommé en main
git branch -M main 
git remote add origin https://github.com/.../...git
git push -u origin main

```

## Configurer git

```bash
# config du commiter
git config --global user.email "myemail@domain.com"
git config --global user.name "My NAME"

# config du terminal
git config --global color.dif auto
git config --global color.status auto
git config --global color.branch auto
git config --global core.editor nano
git config --global mergetool vimdiff
```

## Astuces

### Créer une branche et se positionner dedans

```bash
# solution 1
git branch MyNewfeature
git checkout MyNewfeature

# solution 2
git checkout -b MyNewfeature2
```

### merger une branche sur une autre

Dans l'exemple, on veux merger la branche MyNewfeature sur main.

```bash
# se positioner sur la branche de destination
git checkout main
git merge MyNewfeature
```

## Renommer la branche master en main

Tout d'abord, merger toutes les branches en cours sur master quand c'est possible.
 Quand ce n'est pas possible, il faudra faire un rebase des autres branches sur la branche main lorsqu'elle sera faite (je crois->pas testé encore)

 ```bash
 # En local renommer la branche en main 
 git branch --move master main
 git push -u origin main

# En remote, on se retrouve avec une branche master et une branche main
# sur github (interface web) définir la branche main comme branche par défaut
# puis on supprime la branche master
git push origin --delete master

# Et enfin il faut paramétrer refs/remotes/origin/HEAD
git remote set-head origin main

 ```
