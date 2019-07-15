# Ajouter de l'autocompletion à la commande ssh
source: https://unix.stackexchange.com/questions/136351/autocomplete-server-names-for-ssh-and-scp

Au fur et à mesure qu'on se connecte à de nouveau serveur, l'autocompletion s'enrichit

Il faut modifier ~/.ssh/config et /etc/ssh/ssh_config
en ajoutant: 

```bash
HashKnownHosts no
```
Ceci permet de ne plus 'hasher' les hosts dans le fichier known_hosts.

Créer un fichier /etc/bash_completion.d/ssh avec:

```bash
_ssh() 
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts=$(grep '^Host' ~/.ssh/config ~/.ssh/config.d/* 2>/dev/null | grep -v '[?*]' | cut -d ' ' -f 2-)

    COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
    return 0
}
complete -F _ssh ssh
```

