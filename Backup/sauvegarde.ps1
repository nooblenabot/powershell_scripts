##########################################################
# Script: sauvegarde.ps1
# Author: Fabien DUCHAMP
# Date  : 6 juin 2012
# Desc  : Script permettant le lancement des sauvegardes programm�s dans conf_sauvegarde.csv
# 
#
# 
#
##########################################################

$global:TimesStart = Get-date -Format 'dddd dd MMM yyyy'
$global:HourStart = Get-Date -Format 'HH"h"mm'

# D�finition du nom de la machine, NE PAS MODIFIER
$global:hname = hostname

[string]$global:path = get-location
[string]$global:pathrapport = $path+"\rapports\"
#������������������D�but du script���������������������-

#D�finition des variables

#nom du client
$global:client=(get-content Variables.txt -totalcount 24)[0]

# D�finition du serveur SMTP
$global:emailserver=(get-content Variables.txt -totalcount 24)[2]

# D�finition du port du serveur SMTP
$global:portsmtp=(get-content Variables.txt -totalcount 24)[3]

# Si SMTP authentifi� mettre la variable � 1
$global:smtpauth = (get-content Variables.txt -totalcount 24)[4]

# Si SMTP authentifi� renseignez le nom d'utilisateur et mot de passe, n'oubliez pas de modifier le port d'envoie du SMTP
$global:usersmtpauth = (get-content Variables.txt -totalcount 24)[5]
$global:mdpsmtpauth = (get-content Variables.txt -totalcount 24)[6]

# D�finition de l'exp�diteur
$global:emailfrom=(get-content Variables.txt -totalcount 24)[7]

# D�finition du destinataire, possible de mettre un autre destinataire � la suite en s�parant les adresses par ;
$global:emailto=(get-content Variables.txt -totalcount 24)[8]

# import des informations de configuration des sauvegardes
$csv = import-csv "$path\conf_sauvegarde.csv" -delimiter ";"

foreach ($colonne in $csv) 
{
	[int]$global:numero_sauv = $colonne.nbre
	$global:nom_sauv = $colonne.nom_sauv
	$global:source = $colonne.source
	$global:destination = $colonne.destination
	$global:complete = $colonne.complete
	# la variable historiquemax sert pour le script compteur.ps1
	[int]$global:historiquemax = $colonne.historiquemax
	$global:type_sauv = $colonne.type_sauv
	
	# Variable ou les fichiers de log sont enregistr�s"
$global:backuplog= $pathrapport +(get-date -f MM-dd-yyyy )+"_"+$hourstart+"_backup_"+$nom_sauv+".log"
				
	
	# je d�fini ces lettres pour les rajouter dans la destination (robocopy,ntbackup), c'est plus simple :)
	# c pour complete
	$global:c = "c"
	# i pour incrementale
	$global:incr = "i"

	# lancement des script suivant la colonne type_sauv
	if ($type_sauv -like "robocopy")
	{
	.\script\robocopy.ps1
	}
	elseif ($type_sauv -like "wbadmin")
	{
	.\script\wbadmin.ps1
	}
	elseif ($type_sauv -like "wbadminV")
	{
	.\script\wbadminV.ps1
	}
	elseif ($type_sauv -like "ntbackup")
	{
	.\script\ntbackup.ps1
	}
	elseif ($type_sauv -like "ntbackupB")
	{
	.\script\ntbackupB.ps1
	}
	
# cr�ation d'un index.txt donnant pour le nom du r�pertoire la date de derni�re sauvegarde

add-content -path "$destination$newcompteur.txt" "$timesstart $hourstart"	


}
#�������������������Fin du script����������������������