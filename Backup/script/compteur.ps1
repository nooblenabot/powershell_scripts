##########################################################
# Script: compteur.ps1
# Author: Fabien DUCHAMP
# Date  : 6 juin 2012
# Desc  : Script permettant d'incrémenter +1 la sauvegarde robocopy
# 
#
# 
#
##########################################################

	#on créé les fichiers compteurs pour chaque sauvegarde

foreach ($numero_fic in $numero_sauv )	
{
$pathfichier = "$path\script\compteur\compteur$numero_fic"+".txt"
$testpath = Test-Path $pathfichier

if ($testpath -match "false")   
{
    set-content -path $pathfichier "0"
	
	
}

}


write-host $pathfichier -foreground red

# Nomination des lignes du fichier
	[int]$i=1
	[int] $chiffre_fichier = gc $pathfichier
	 [int]$compteur = $chiffre_fichier
	
# On vérifie quel chiffre figure dans chaque fichier

write-host $compteur -foreground cyan

	# si le compeur est inférieur à l'historique max on rajoute +1 | LA VARIABLE HISTORIQUEMAX EST RECUPERE DU CSV DE ROBOCOPY VIA $global
		if($compteur -lt $historiquemax)
				{
				$global:newcompteur = $compteur + $i
				write-host $newcompteur -foreground green
				}	

	# si le compteur est à zéro on le passe à 1
	 elseif($compteur -eq 0)
				{
				[int]$compteur = 1
				write-host $compteur -foreground yellow
				}

	 
 
 # si le compteur est supérieur ou égal à l'historique max on le met à 1
		elseif ($compteur -ge $historiquemax)
				{
				$global:newcompteur = 1
				write-host $newcompteur -foreground red
				} 
 

set-content -path $pathfichier "$newcompteur"

 
 start-sleep -milliseconds 3600

