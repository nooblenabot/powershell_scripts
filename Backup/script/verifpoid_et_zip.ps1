##########################################################
# Script: sauvegarde via robocopy
# Author: Fabien DUCHAMP
# Date  : 05 juillet 2012
# Desc  : Script permettant de récupérer le poids de la pièce jointe et de la zipper si trop grosse
# 
##########################################################
$path = "c:\gi\sauvegarde"
$gcibackuplog = gci $backuplog

# on va vérifier le poid du fichier de log en cours dans la variable backuplog

[int]$Total = 0

$gcibackuplog | foreach-object { $Total += $_.length } 

$Total /= (1024*1024)

write-host "$Total Mo"

$nomfichier = $gcibackuplog.name

# si le fichier est supérieur à 10Mo on le zip

function compression ()
{
$7z = "$path\script\7z.exe"
$args = "a -mx7 $path\rapports\$nomfichier.zip $backuplog"

if ($total -ge 10)
{
Start-Process -FilePath "$7z" -ArgumentList "$args" 
$global:backuplog = $backuplog+".zip"

}

}

# appel de la fonction

compression


