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

## Convertir de l'epoch time

```bash
# epoch tim to date
select to_date('19700101', 'YYYYMMDD') + ( 1 / 24 / 60 / 60 / 1000) * 1655109600000
from dual;

# date to epoch time
select (to_date('13/06/2022 08:40:00', 'DD/MM/YYYY HH24:MI:SS') - to_date('19700101', 'YYYYMMDD')) * 24 * 60 * 60 * 1000
from dual;
```