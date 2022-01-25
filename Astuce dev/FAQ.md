## Commande en vrac

### Installation de gradle wrapper sur un projet

pré-requis : avoir une version de graddle déjà installée sur le poste
```bash
gradle wrapper --gradle-version <version>
```
Cette commande génère l'arboresscence suivante dans le projet
```bash
gradle
├── wrapper
│   ├── gradle-wrapper.jar
│   └── gradle-wrapper.properties
```

## Afficher tous les warnings d'un build gradle

Pratique lors de migration de version de gradle

```bash
./gradlew clean build --warning-mode all
```

