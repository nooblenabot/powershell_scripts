##########################################################
# Script: wbadmin.ps1
# Author: Fabien DUCHAMP
# Date  : 6 juin 2012
# Desc  : Script permettant la sauvegarde complète d'un serveur
# 
#
# 
#
##########################################################

# Définition du répertoire de destination

$day=(get-date).dayofweek
New-Item \\127.0.0.1\backup$\$day -type directory
#New-Item d:\VMS\SRV -type directory

$backuplocation= $destination+$day
#fonction sauvegarde
function SauvegardeWBADMIN
{


$Error.Clear()
		
		Write-Output ("———————– Début de sauvegarde le – $(Get-Date –f o) ————————-") | Out-File "$backuplog" -Append
		
		#wbadmin start backup -backupTarget:$backuplocation\VMS\SRV\ -hyperv:751DF495-A238-438A-A5DB-F817CF185CA9 -allowDeleteOldBackups -vssfull -quiet| Out-File "$backuplog" -Append
		wbadmin start backup -backupTarget:$backuplocation -allcritical -vssfull -quiet| Out-File "$backuplog" -Append
						
		if(!$?)
		{
		$global:sujet= $client+'", sauvegarde echouee de "'+$hname
		$global:corps= '"Une erreur c est produite! Verifier le journal en piece jointe"'
		$global:backuplog 
        Write-Output ("———————– Une erreur c'est produite! Verifier le journal en pièce jointe. – $(Get-Date –f o) ————————-") | Out-File "$backuplog" -Append
		.\script\verifpoid_et_zip.ps1
        .\script\envoiemail.ps1
		}
		else
		{
        $global:sujet= $client+'", Sauvegarde OK "'+$hname
		$global:corps= '"La sauvegarde a reussi pour "'+$hname
		
		Write-Output ("———————– Sauvegarde OK! – $(Get-Date –f o) ————————-") | Out-File "$backuplog" -Append
		.\script\verifpoid_et_zip.ps1
		.\script\envoiemail.ps1
        }
		
		


}



# LANCEMENT DE LA SAUVEGARDE en appelant la fonction SauvegardeWBADMIN

SauvegardeWBADMIN



#——————————————————–Fin du script——————————————————————