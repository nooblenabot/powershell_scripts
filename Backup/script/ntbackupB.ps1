# filename: ntbackupB.ps1
# author: john
# created: 02/08/2011
#
# Modifif� le 03/01/2012 par F.Duchamp
#
#
########################################################################################

$day=(get-date).dayofweek
$UserProfile = $env:userprofile

# D�finition du .bks a utiliser pour la sauvegarde
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

# Nom du fichier BKF
$BackupFile = "$destination$nom_sauv.bkf"
# Emplacement de l'exe ntbackup
$ntbackup = "C:\WINDOWS\system32\ntbackup.exe"
if ($complete -match "oui")
{
$args = @("backup `"@$BksFileName`"","/n `"$nom_sauv$yyyymmdd`"","/v:yes","/r:no","/rs:no","/hc:on","/m normal","/l:s","/um","/p `"$destination`",")
}
elseif ($complete -match "non")
{
$args = @("backup `"@$BksFileName`"","/n `"$nom_sauv$yyyymmdd`"","/v:yes","/r:no","/rs:no","/hc:on","/m incremental","/l:s","/um","/p `"$destination`",")
}
#Run the backup job - and wait for it to finish
Write-Host -ForegroundColor Green "Debut de la sauvegarde"
Write-Output ("�������� D�but de sauvegarde le � $(Get-Date �f o) ��������-") | add-Content -Path $backuplog

Start-Process -FilePath $ntbackup -ArgumentList $args -Wait | add-Content -Path $backuplog

#Now check everything went OK

$BACKUPCOMPLETED = "sauvegarde termin�e" # "Backup completed" line in the log file in your system language
$VERIFYCOMPLETED = "v�rification termin�e" # "Verify completed" line in the log file in your system language
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

Write-Output ("�������� Sauvegarde OK! � $(Get-Date �f o) ��������-") | add-Content -Path $backuplog

		$global:sujet= $client+'", Sauvegarde OK "'+$hname
		$global:corps= '"La sauvegarde a reussi pour "'+$hname
		.\script\verifpoid_et_zip.ps1
		.\script\envoiemail.ps1


}
#lancement de la sauvegarde en appelant la fonction launch_ntbackup

launch_ntbackup
