##########################################################
# Script: envoiemail.ps1 
# Author: Fabien DUCHAMP
# Date  : 12 juin 2012
# Desc  : Script permettant l'envoie de mail
# 
#
# 
#
##########################################################

#fonction envoie de mail
function SendEmail()
{
$blat = "$path\script\blat\blat.exe"
$args = "-to $emailto -f $emailfrom -subject $sujet -body $corps -server $emailserver -port $portsmtp -attach $backuplog -log $path\script\logmail\blat.txt"
$argsauthsmtp = "-u $usersmtpauth -pw $mdpsmtpauth"

if ($smtpauth -eq 0)
{
Start-Process -FilePath "$blat" -ArgumentList "$args"
}
elseif ($smtpauth -eq 1)
{
Start-Process -filepath "$blat" -argumentlist "$args $argsauthsmtp"
}
}

SendEmail