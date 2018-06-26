# Convertir un vmdk en vdi
Faire une sauvegarde avant tout.

Sur la machine hôte
```bash
<chemin de virtualbox>\vboxmanage.exe clonehd mon_fichier_origine.vmdk mon_nouveau_fichier.vdi --format VDI
```

Puis changer dans virtualbox le fichier vmdk par le vdi.

Si ok supprimer le vdi

# Réduire la taille d'un .vdi
Faire une sauvegarde avant tout.
## sur une machine linux
Installer zerofree
```bash
sudo apt-get install zerofree
```

Entrer dans le menu grub
sur virtualbox, redémarrer la vm en laissant `Shift` Appuyé

Dans le menu grub choisir `recovery mode`

Selectionner le menu `root` dans `recovery mode`

Regarder le nom du disque à réduire
```bash
df
```

Monter la partition en read only
```bash
mount -n -o remount,ro -t ext4 /dev/sda1 /
```

Lancer zerofree
```bash
zerofree /dev/sda1
```

Eteindre la vm
```bash
shutdown -h now
```

Sur l'environnement de l'hôte (dans mon cas un windows)
```bash
<chemin de virtualbox>\vboxmanage.exe modifyhd mon_fichier.vdi compact
```

# Retailler un vdi
Sur la machine hôte
```bash
# Dans l'exemple, on passe le disque à 20Go
<chemin de virtualbox>\vboxmanage.exe modifyhd mon_fichier_origine.vdi --resize 20480
```

# Déplacer le home directory sur un autre disque
source: https://help.ubuntu.com/community/Partitioning/Home/Moving

Récupérer les uuid des disque
```bash
sudo blkid
```

```bash
sudo vim /etc/fstab
# ajouter ces lignes dans fstab
# (identifier)  (location, eg sda5)   (format, eg ext3 or ext4)      (some settings) 
UUID=<uuid récupérer précédement>   /media/home    ext4          defaults       0       2
```

Se placer dans le répertoire et monter le disque
```bash
sudo mkdir /media/home
sudo mount -a
```

Copier les données de votre home actuel sur le nouveau disque
```bash
# copie
sudo rsync -aXS --exclude='/*/.gvfs' /home/. /media/home/.
# vérification de la copie
sudo diff -r /home /media/home -x ".gvfs/*"
```

Il ne reste plus qu'à modifier dans /etc/fstab la ligne suivante
```bash
UUID=<uuid récupérer précédement>   /media/home    ext4          defaults       0       2
```
```bash
# (identifier)  (location, eg sda5)   (format, eg ext3 or ext4)      (some settings) 
UUID=<uuid récupérer précédement>   /home    ext4          defaults       0       2
```

Et monter les disques
```bash
sudo mount -a
```

# Installer les virtualbox guest addition sur centos
## pré-requis
```bash
yum install -y gcc kernel-devel kernel-headers dkms make bzip2 perl
echo 'export KERN_DIR=/usr/src/kernels/`uname -r`' > /etc/profile.d/vbox_var.sh
reboot
```
## installation des guest addition
Cliquer sur Install Guest Additions… depuis le menu périphériques
```bash
mount /media/cdrom
sh /media/cdrom/VBoxLinuxAdditions.run
```

