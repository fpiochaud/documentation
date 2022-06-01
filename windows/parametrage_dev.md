# Paramètrage de l'environnement de développement avec WSL2.

Pré-requis, il faut installer WSL sur le poste windows
voir [Installation de WSL](wsl/wsl.md)

## 1) installation pour la partie Frontend

Dans mon cas, Frontend en angular

**Pré-requis si vous êtes en entreprise**

Si vous utilisez votre propre certificat, ajouter le fichier ~/.curlrc

```bash 
# fichier ~/.curlrc
-k 
```

Si votre entrerpise a un proxy, ajouter les variables HTTP_PROXY, HTTPS_PROXY et FTP_PROXY. Perso, je préfère ajouter un fichier de conf dans /etc/profile.d/proxy

(ne pas oublier de paramétrer le gestionnaire de paquet apt, yum ou autre en fonction de la distribution linux)

### a) Install node 

Pour pouvoir gérer plusieurs versions de node, il est préférable d'installer nvm (node version manager)

```bash
sudo apt install curl nodejs
curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
source ~/.profile
```

**Installation de Node avec nvm**

Soit : \
installer node 

```bash 
nvm install node
```

ou: 
installer la dernier version LTS de node

```bash 
nvm install --lts
```

ou: 
Installer la version de node désirée
```bash 
nvm install v16.14.0
# et la définir par défaut
nvm alias default v16.14.0
```

Fichier de conf npm et yarn pour le cas ou on a un repo local

```bash
# fichier ~/.npmrc
registry=https://artifactory.foo.bar/artifactory/api/npm/npm
strict-ssl=false

# fichier ~/.yarnrc
registry "https://artifactory.foo.bar/artifactory/api/npm/npm"
strict-ssl false
```

### b) Installation yarn
Sous WSL

`npm install -g yarn`

### c) Installation du cli angular

```bash
yarn global add @angular/cli
```

### d) Installation de Yeoman

```bash
yarn global add yo
```

## 2) Installation pour la partie Backend

Dans mon cas, backend en java (springboot)

### a) Installation java (avec la possibilité de switcher de version)

Je gère plusieurs projets avec des versions java différentes, je veux pouvoir passer d'un projet à l'autre sans soucis.

```bash
sudo apt install default-jdk openjdk-8-jdk openjdk-17-jdk
```

Pour lister les versions java installer:

```bash
$ sudo update-java-alternatives -l
java-1.11.0-openjdk-amd64      1111       /usr/lib/jvm/java-1.11.0-openjdk-amd64
java-1.17.0-openjdk-amd64      1711       /usr/lib/jvm/java-1.17.0-openjdk-amd64
java-1.8.0-openjdk-amd64       1081       /usr/lib/jvm/java-1.8.0-openjdk-amd64
```

Pour basculer sur jvm

```bash
$ sudo update-java-alternatives -s java-1.11.0-openjdk-amd64
# ou
$ sudo update-java-alternatives -s java-1.17.0-openjdk-amd64
# ou
$ sudo update-java-alternatives -s java-1.8.0-openjdk-amd64
```

PS: dans ma configuration j'ai ce message d'erreur (mais génant dans mon cas):

```bash
$ sudo update-java-alternatives -s java-1.11.0-openjdk-amd64
update-alternatives: error: no alternatives for mozilla-javaplugin.so

$ sudo update-java-alternatives -s java-1.17.0-openjdk-amd64
update-alternatives: error: no alternatives for mozilla-javaplugin.so

$ sudo update-java-alternatives -s java-1.8.0-openjdk-amd64
update-alternatives: error: no alternatives for mozilla-javaplugin.so
update-java-alternatives: plugin alternative does not exist: /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/IcedTeaPlugin.so
```

Pour ajouter des certificats au cacerts des jvm:
le cacert est partagée à toutes les JVM. 
Chemin du fichier: /etc/ssl/certs/java/cacerts

```bash
# pour importer un certificat
$ keytool -import -trustcacerts -alias my_root_cert -file my_cert_file.crt -keystore /etc/ssl/certs/java/cacerts -storepass changeit
```