# filename: ntbackup.ps1
# author: john
# created: 02/08/2011
#
# Modififé le 03/01/2012 par F.Duchamp
########################################################################################

$day=(get-date).dayofweek
$UserProfile = $env:userprofile

# Définition du .bks a utiliser pour la sauvegarde
$BksFileName = $userprofile+"\Local Settings\Application Data\Microsoft\Windows NT\NTBackup\data\"+$source+".bks"

# Description de la sauvegarde
$SetDescription = "cree le $timestart"

#################################################################################################

$tddt = (Get-Date).ToString('dd/MM/yyyy')
$yyyymmdd = (Get-Date).ToString('ddMMyyyy')
$tdt = (Get-Date).ToString('HH:mm')

#fonction lancement ntbackup
function launch_ntbackup
{

$LOGFILEDIR = "$userprofile\Local Settings\Application Data\Microsoft\Windows NT\NTBackup\data"
remove-item -path "$userprofile\Local Settings\Application Data\Microsoft\Windows NT\NTBackup\data\*.log"
remove-item -path $path\*.log

#lancement du compteur
.\script\compteur.ps1
start-sleep -milliseconds 3600

# Nom du fichier BKF
#$BackupFile = ""
# Emplacement de l'exe ntbackup
$ntbackup = "C:\WINDOWS\system32\ntbackup.exe"
if ($complete -match "oui")
{
$args = @("backup `"@$BksFileName`"","/n `"$nom_sauv`"","/d `"$SetDescription`"","/v:yes","/r:no","/rs:no","/hc:off","/m normal","/j `"$nom_sauv`"","/l:s","/f `"$destination$nom_sauv$newcompteur$c.bkf`"")
}
elseif ($complete -match "non")
{
$args = @("backup `"@$BksFileName`"","/n `"$nom_sauv`"","/d `"$SetDescription`"","/v:yes","/r:no","/rs:no","/hc:off","/m incremental","/j `"$nom_sauv`"","/l:s","/f `"$destination$nom_sauv$newcompteur$incr.bkf`"")
}
#Run the backup job - and wait for it to finish
Write-Host -ForegroundColor Green "Debut de la sauvegarde"
Write-Output ("———————– Début de sauvegarde le – $(Get-Date –f o) ————————-") | add-Content -Path $backuplog

Start-Process -FilePath $ntbackup -ArgumentList $args -Wait | add-Content -Path $backuplog

#Now check everything went OK



$BACKUPCOMPLETED = "sauvegarde terminée" # "Backup completed" line in the log file in your system language
$VERIFYCOMPLETED = "vérification terminée" # "Verify completed" line in the log file in your system language
$ERROR = "Erreur" # "Error" in your system language

move-item -path "$userprofile\Local Settings\Application Data\Microsoft\Windows NT\NTBackup\data\backup*.log" -destination $path\backup.log -force
get-content -path $path\backup.log | add-content -path $backuplog

# find file containg this runs nom_sauv
foreach ($file in get-childitem $path\backup.log) {
if (Get-Content $file | Select-String -SimpleMatch "$nom_sauv" -quiet) {
$today = $file
break
}
}

if ($today -eq $null)
{
		$global:sujet= $client+'", sauvegarde echouee de "'+$nom_sauv
		$global:corps= '"Une erreur c est produite! Verifier le journal en piece jointe"'
.\script\verifpoid_et_zip.ps1
.\script\envoiemail.ps1
break
  }

# open file and count lines
$iBackup = (Get-Content $today | Select-String -SimpleMatch "$BACKUPCOMPLETED" | Measure-Object -Line).Lines
$iVerify = (Get-Content $today | Select-String -SimpleMatch "$VERIFYCOMPLETED" | Measure-Object -Line).Lines
$iErrors = (Get-Content $today | Select-String -SimpleMatch "$ERROR" | Measure-Object -Line).Lines

if ($iErrors -gt 0) 
{ 
		$global:sujet= $client+'", sauvegarde echouee de "'+$nom_sauv
		$global:corps= '"Une erreur c est produite! Verifier le journal en piece jointe"'
		.\script\verifpoid_et_zip.ps1
		.\script\envoiemail.ps1
break
}

Write-Output ("———————– Sauvegarde OK! – $(Get-Date –f o) ————————-") | add-Content -Path $backuplog

		$global:sujet= $client+'", Sauvegarde OK "'+$hname
		$global:corps= '"La sauvegarde a reussi pour "'+$hname
		.\script\verifpoid_et_zip.ps1
		.\script\envoiemail.ps1


}
#lancement de la sauvegarde en appelant la fonction launch_ntbackup

launch_ntbackup
