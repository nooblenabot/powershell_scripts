##########################################################
# Script: sauvegarde via robocopy
# Author: Fabien DUCHAMP
# Date  : 14 mai 2012
# Desc  : Script permettant la sauvegarde de r�pertoire via robocopy
# 
##########################################################

function func_robocopy ()
{

# lancement du compteur
.\script\compteur.ps1
start-sleep -milliseconds 3600

	# Lancement des sauvegardes Robocopy

	# si la variable complete est �gale � oui on lance toujours une sauvegarde compl�te
if ($complete -match "oui")
{
robocopy $source $destination$newcompteur$c /MIR /SEC /V /NP /R:1 /W:2 > $backuplog
$LASTEXITCODE
}
	# si la variable complete est �gale � non on lance toujours une sauvegarde incr�mentale vu que le vendredi une compl�te est faite
elseif ($complete -match "non")
{
robocopy $source $destination$newcompteur$incr /MIR /SEC /M /V /NP /R:1 /W:2 > $backuplog
$LASTEXITCODE
}


# rappel des codes d'exit de robocopy
$ExitCode = @{
"16"="Erreur fatale lors de l'op�ration. Voir fichier de Log"
"15"="Echec de la copie. Voir le fichier de Log."
"14"="Echec de la copie. Voir le fichier de Log."
"13"="Echec de la copie. Voir le fichier de Log."
"12"="Echec de la copie. Voir le fichier de Log."
"11"="Echec de la copie. Voir le fichier de Log."
"10"="Echec de la copie. Voir le fichier de Log."
"9"="Echec de la copie. Voir le fichier de Log."
"8"="Echec de la copie. Plisieurs fichiers n'ont pas �t� copi�s. Voir le fichier de Log."
"7"="Echec de la copie. Certains fichiers pr�sents et suppl�mentaires ont g�n�r�s une incoh�rence entre la source 
et la destination. Voir le fichier de Log."
"6"="Echec de la copie. Certains fichiers et dossiers supl�mentaires ont g�n�t� une incoh�rence entre la source 
et la destination. Voir le fichier de Log."
"5"="Echec de la copie. Certains fichiers ont �t� copi�s et d'autres ont g�n�r� une incoh�rence entre la source 
et la destination. Voir le fichier de Log."
"4"="Echec de la copie. Une incoh�rence entre la source et la destination de la sauvegarde a �t� d�tect�e. Voir 
le fichier de Log."
"3"="Copie OK. Certains fichiers suppl�mentaires ont �t� copi�s avec succ�s."
"2"="Copie OK. Certains fichiers ou r�pertoires suppl�mentaires ont �t� d�tect�s et copi�s avec succ�s."
"1"="Copie OK. Un ou plusieurs fichiers ont �t� copi�s avec succ�s du r�pertoire source au r�pertoire 
de destination."
"0"="Copie OK. Aucun changement. Le r�pertoire source �tait identique au r�pertoire de destination."
}

# si le code exit de robocopy est sup�rieur ou �gal � 4, cela signifie que la sauvegarde est en �chec
if ($lastexitcode -ge 4)
	{
	$global:sujet= $client+'", sauvegarde echouee de "'+$nom_sauv
	$global:corps= '"Une erreur c est produite! Verifier le journal en piece jointe"'
		.\script\verifpoid_et_zip.ps1
        .\script\envoiemail.ps1
        
       
    }
	
# si le code exit de robocopy est sup�rieur ou �gal � 0, cela signifie que la sauvegarde est ok
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


