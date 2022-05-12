# Paramètrage de l'environnement de développement.

## Installation yarn

Deux solutions: 
- soit installer via un .msi https://classic.yarnpkg.com/lang/en/docs/install/#windows-stable\
- Soit l'installer via chocolatey via une console powershell

```bash
choco install yarn
```

Il faut également créer une variable d'environnement YARN_HOME, dans la partie variable système:\
`YARN_HOME=C:\Users\{username}\AppData\Local\Yarn\bin`\
et ajouter cette variable à la variable PATH (et redémarrer le PC pour la prise en compte). C'est dans ce répertoire ou est installé les modules globaux.

## Switch de version de java

Aprés avoir installer, les différentes versions de java nécessaire.
Dans mon cas, ce sont des installations de openJDK :
- C:\Program Files\RedHat\java-1.8.0-openjdk-1.8.0.312-2
- C:\Program Files\RedHat\java-17-openjdk-17.0.2.0.8-1

Déclarer les variables systèmes suivantes:
JAVA8_HOME=C:\Program Files\RedHat\java-1.8.0-openjdk-1.8.0.312-2
JAVA17_HOME=C:\Program Files\RedHat\java-17-openjdk-17.0.2.0.8-1
et
Ajouter à la variable Path:
%JAVA_HOME%\bin

Déclarer une variable Utilisateur:
JAVA_HOME=%JAVA8_HOME%
ou
JAVA_HOME=%JAVA17_HOME%

Puis redémarrer le PC.

On peux ensuite créer des scripts pour switcher rapidement de jvm

exemple1: 

``` bash
# java8.bat
@echo off
set JAVA_HOME=%JAVA8_HOME%
setx JAVA_HOME "%JAVA_HOME%" 
set Path=%JAVA_HOME%\bin;%JAVA_HOME%\jre\bin;%Path%
java -version
```

exemple2: 

``` bash
# java17.bat
@echo off
set JAVA_HOME=%JAVA17_HOME%
setx JAVA_HOME "%JAVA_HOME%" 
set Path=%JAVA_HOME%\bin;%JAVA_HOME%\jre\bin;%Path%
java -version
```
