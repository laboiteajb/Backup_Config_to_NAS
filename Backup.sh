#!/bin/bash
clear
echo ############
# Username
User='scotch'
echo Votre User:$User
echo ############
# Rétention des fichiers
Sauv='1M' # 1 Mois - ms|s|m|h|d|w|M|y
echo Rétention de vos fichiers:$Sauv
echo ############
# Chemin des applications
PathRadarr=/home/$User/.config/Radarr/Backups/scheduled/*
PathSonarr=/home/$User/.config/NzbDrone/Backups/scheduled/*
PathJackett=/home/$User/.config/Jackett/*
PathRclone=/home/$User/.config/rclone/rclone.conf
PathSyncthing=/home/$User/.config/syncthing/*
##
# Suppression du dossier de Backup
rm /tmp/Backup/ -R 2>&1

# Création du dossier Backup
mkdir /tmp/Backup

###################################
###################################
echo ############
echo Backup Radarr
# Backup Radarr
mkdir /tmp/Backup/Radarr

# Copie des Backups
cp $PathRadarr /tmp/Backup/Radarr -r

# Compression du dossier
tar czvf /tmp/Backup/Radarr_`date +%Y-%m-%d_%H-%M`.tar.gz /tmp/Backup/Radarr 2>&1 | grep "something"

# Suppression du dossier de Backup Radarr
rm /tmp/Backup/Radarr -r

###################################
###################################
echo ############
echo Backup Sonarr
# Backup Sonarr
mkdir /tmp/Backup/Sonarr

# Copie des Backups
cp $PathSonarr /tmp/Backup/Sonarr -r

# Compression du dossier
tar czvf /tmp/Backup/Sonarr_`date +%Y-%m-%d_%H-%M`.tar.gz /tmp/Backup/Sonarr 2>&1 | grep "something"

# Suppression du dossier de Backup Sonarr
rm /tmp/Backup/Sonarr -r

###################################
###################################
echo ############
echo Backup Jackett
# Backup Jackett
mkdir /tmp/Backup/Jackett

# Arret du service Jackett
systemctl stop jackett.service

# Copie des Fichiers
cp $PathJackett /tmp/Backup/Jackett -r

# Démarrage du service Jackett
systemctl start jackett.service

# Compression du dossier
tar czvf /tmp/Backup/Jackett_`date +%Y-%m-%d_%H-%M`.tar.gz /tmp/Backup/Jackett 2>&1 | grep "something"

# Suppression du dossier de Backup Jackett
rm /tmp/Backup/Jackett -r

###################################
###################################
echo ############
echo Backup Rclone
# Backup Rclone
mkdir /tmp/Backup/Rclone

# Copie de la configuration de Rclone
cp $PathRclone /tmp/Backup/Rclone -r

# Compression du dossier
tar czvf /tmp/Backup/Rclone_`date +%Y-%m-%d_%H-%M`.tar.gz /tmp/Backup/Rclone 2>&1 | grep "something"

# Suppression du dossier de Backup Rclone
rm /tmp/Backup/Rclone -r

###################################
###################################
echo ############
echo Backup Syncthing
# Backup Syncthing
mkdir /tmp/Backup/Syncthing

# Arret du service Syncthing
systemctl stop syncthing@$User.service

# Copie des Fichiers
cp $PathSyncthing /tmp/Backup/Syncthing -r

# Démarrage du service Syncthing
systemctl start syncthing@$User.service

# Compression du dossier
tar czvf /tmp/Backup/Syncthing_`date +%Y-%m-%d_%H-%M`.tar.gz /tmp/Backup/Syncthing 2>&1 | grep "something"

# Suppression du dossier de Backup Syncthing
rm /tmp/Backup/Syncthing -r

###################################
###################################
echo ############
echo Attribution des fichiers à $User
# Attribution des fichiers à votre utilisateur
chown $User:$User /tmp/Backup/*.tar.gz

echo Trasfert des fichiers
# Trasfert des fichiers
runuser -l $User -c 'rclone copy /tmp/Backup/Radarr* NAS:/Backup/Apps/Radarr' 
runuser -l $User -c 'rclone copy /tmp/Backup/Sonarr* NAS:/Backup/Apps/Sonarr'
runuser -l $User -c 'rclone copy /tmp/Backup/Jackett* NAS:/Backup/Apps/Jackett'
runuser -l $User -c 'rclone copy /tmp/Backup/Rclone* NAS:/Backup/Apps/Rclone'
runuser -l $User -c 'rclone copy /tmp/Backup/Syncthing* NAS:/Backup/Apps/Syncthing'

echo Suppression des sauvegardes
# Suppression des sauvegardes
runuser -l $User -c 'rclone delete --min-age 1M NAS:/Backup/Apps/Radarr'
runuser -l $User -c 'rclone delete --min-age 1M NAS:/Backup/Apps/Sonarr'
runuser -l $User -c 'rclone delete --min-age 1M NAS:/Backup/Apps/Jackett'
runuser -l $User -c 'rclone delete --min-age 1M NAS:/Backup/Apps/Rclone'
runuser -l $User -c 'rclone delete --min-age 1M NAS:/Backup/Apps/Syncthing'

# Suppression du dossier Backup
rm /tmp/Backup -R

echo Fin du script
echo ##################################################################