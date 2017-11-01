##########################################################
# Script: sauvegarde via robocopy
# Author: Fabien DUCHAMP
# Date  : 14 mai 2012
# Desc  : Script permettant la sauvegarde de répertoire via robocopy
# 
##########################################################

function func_robocopy ()
{

# lancement du compteur
.\script\compteur.ps1
start-sleep -milliseconds 3600

	# Lancement des sauvegardes Robocopy

	# si la variable complete est égale à oui on lance toujours une sauvegarde complète
if ($complete -match "oui")
{
robocopy $source $destination$newcompteur$c /MIR /SEC /V /NP /R:1 /W:2 > $backuplog
$LASTEXITCODE
}
	# si la variable complete est égale à non on lance toujours une sauvegarde incrémentale vu que le vendredi une complète est faite
elseif ($complete -match "non")
{
robocopy $source $destination$newcompteur$incr /MIR /SEC /M /V /NP /R:1 /W:2 > $backuplog
$LASTEXITCODE
}


# rappel des codes d'exit de robocopy
$ExitCode = @{
"16"="Erreur fatale lors de l'opération. Voir fichier de Log"
"15"="Echec de la copie. Voir le fichier de Log."
"14"="Echec de la copie. Voir le fichier de Log."
"13"="Echec de la copie. Voir le fichier de Log."
"12"="Echec de la copie. Voir le fichier de Log."
"11"="Echec de la copie. Voir le fichier de Log."
"10"="Echec de la copie. Voir le fichier de Log."
"9"="Echec de la copie. Voir le fichier de Log."
"8"="Echec de la copie. Plisieurs fichiers n'ont pas été copiés. Voir le fichier de Log."
"7"="Echec de la copie. Certains fichiers présents et supplémentaires ont générés une incohérence entre la source 
et la destination. Voir le fichier de Log."
"6"="Echec de la copie. Certains fichiers et dossiers suplémentaires ont génété une incohérence entre la source 
et la destination. Voir le fichier de Log."
"5"="Echec de la copie. Certains fichiers ont été copiés et d'autres ont généré une incohérence entre la source 
et la destination. Voir le fichier de Log."
"4"="Echec de la copie. Une incohérence entre la source et la destination de la sauvegarde a été détectée. Voir 
le fichier de Log."
"3"="Copie OK. Certains fichiers supplémentaires ont été copiés avec succès."
"2"="Copie OK. Certains fichiers ou répertoires supplémentaires ont été détectés et copiés avec succès."
"1"="Copie OK. Un ou plusieurs fichiers ont été copiés avec succès du répertoire source au répertoire 
de destination."
"0"="Copie OK. Aucun changement. Le répertoire source était identique au répertoire de destination."
}

# si le code exit de robocopy est supérieur ou égal à 4, cela signifie que la sauvegarde est en échec
if ($lastexitcode -ge 4)
	{
	$global:sujet= $client+'", sauvegarde echouee de "'+$nom_sauv
	$global:corps= '"Une erreur c est produite! Verifier le journal en piece jointe"'
		.\script\verifpoid_et_zip.ps1
        .\script\envoiemail.ps1
        
       
    }
	
# si le code exit de robocopy est supérieur ou égal à 0, cela signifie que la sauvegarde est ok
elseif ($lastexitcode -ge 0)
	{
	$global:sujet= $client+'", Sauvegarde OK "'+$nom_sauv
	$global:corps= '"La sauvegarde a reussi pour "'+$nom_sauv
	.\script\verifpoid_et_zip.ps1
	.\script\envoiemail.ps1

start-sleep -milliseconds 3600
}



#fin foreach
}




#lancement sauvegarde via function robocopy





func_robocopy


