# 
# script pour l'import en masse des eleves dans l'AD
# 
# Creation du compte dans l'AD avec les parametres suivants : nom, prenom, compte, nom affiche, profil, OU, generation du mot de passe a partir de la date de naissance, conservation de la date de naissance dans le champ FAX (ou telecopie),
# on a juste besoin des valeurs suivantes (l'entete doit porter la mention entre parenteses) : NOM (Name), PRENOM (Surname), DATE DE NAISSANCE au format jj/mm/aaaa a fixer dans excel pour conserver les zeros (FAX), CLASSE (classe), NIVEAU (niveau)
# ATTENTION BIEN ENLEVER LES ACCENTS, ESPACES, et CARACTERES SPECIAUX
#========================================================================

#demande du fichier a importer
$fic_import = Read-Host "emplacement et nom du fcihier d'import eleves"
#$reset_pwd = Read-Host "reinitialiser les mots de passes de ancien eleves ?"

#import des modules externes
Import-Module ActiveDirectory 
#Definition des Variables permanantes
$sc = [char]34

#import du fichier utilisateurs
$Users = Import-Csv -Delimiter ";" -Path $fic_import
#creation d'un fichier de logins/password
$ListeLogin = ".\logins_eleves.csv"
Add-content -path $ListeLogin "Eleve,Login,Mot de Passe,classe"

#parcours du fichier d'import
foreach ($User in $Users)
{
    #definition des variables modulee par eleve

    $ou = "OU="+ $User.classe + ",OU=ELEVES,OU=Lycee,DC=Lycee,DC=saintmarie,DC=LOCAL"
	$SamAccountName =  $User.Prenom.substring(0,1)+$User.Nom
	$DisplayName = $User.Nom+" "+$User.Prenom
	$UPN = $User.Prenom.substring(0,1)+$User.nom+"@Lycee.saintmarie.local"
	$HomeDirectory = "\\serveurt01\Eleves_lycee\"+$User.classe+"\ELEVES\%username%"
	$Script = $User.classe+".bat"
	$ProfilePath = "\\serveurt01\Profils$\"+$User.classe+"\"+$SamAccountName
	$repertoire_doc = "\\serveurt01\Eleves_lycee\"+$User.classe+"\ELEVES\"+$SamAccountName
    $GroupProf = "Profs_"+$User.classe
    $Password = $User.Fax
    $Classe = $User.classe
    $Password = $User.Fax
    #$Password = .\New-SWRandomPassword.ps1
    
    #verification de la presence dans l'AD
    $ADUser = Get-ADUser -Filter {(samaccountname -eq $SamAccountName)}

    #creation de ll'utilisateur
    if ($ADUser -eq $NULL)
    {	
        #utilisateur classique n'existant pas encore
        New-ADUser -Surname $User.Nom -GivenName $user.Prenom -Name $DisplayName -SamAccountName $SamAccountName -UserPrincipalName $UPN -DisplayName $DisplayName -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -force) -PasswordNeverExpires $true -CannotChangePassword $false -ChangePasswordAtLogon $False -Enabled $true -ProfilePath $ProfilePath -HomeDrive "U:" -HomeDirectory $HomeDirectory -ScriptPath $Script -Fax $Password -Path $ou
        #ecriture du login/password sur fichier
        Add-content -path $ListeLogin "$sc$DisplayName$sc,$sc$SamAccountName$sc,$sc$Password$sc,$scClasse$sc"
        #ajout de l'utilisateur en tant que membre de son groupe classe
        Add-ADGroupMember -Identity $User.classe -Members $SamAccountName
	    #ceration du repertoire perso de l'eleve
        New-Item $repertoire_doc –Type Directory
        #definition des securite du repertoire perso de l'eleve. seul lui y a acces ainsi que les profs intervenant dans sa classe.
        $acl = Get-Acl $repertoire_doc
        $acl.SetAccessRuleProtection($True, $False)
        $rule_acl = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrateurs","FullControl","ContainerInherit, ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($rule_acl)
        $rule_acl = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrateur","FullControl","ContainerInherit, ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($rule_acl)
        $rule_acl = New-Object System.Security.AccessControl.FileSystemAccessRule("system","FullControl","ContainerInherit, ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($rule_acl)
        $rule_acl = New-Object System.Security.AccessControl.FileSystemAccessRule($SamAccountName,"Modify,DeleteSubdirectoriesAndFiles", "ContainerInherit, ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($rule_acl)
        $rule_acl = New-Object System.Security.AccessControl.FileSystemAccessRule($GroupProf,"Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($rule_acl)
		Set-Acl $repertoire_doc $Acl
    }
    elseif($ADUser -ne $DisplayName)
    {
	    #Generation d'un login différent car un homonyme existe
        #Variables Modifiée du coup
        $SamAccountName =  $User.prenom+$User.nom.substring(0,1)
        $UPN = $User.Prenom+$User.Nom.substring(0,1)+"@college.local"
        
        #creation
        New-ADUser -Surname $User.Nom -GivenName $user.Prenom -Name $DisplayName -SamAccountName $SamAccountName -UserPrincipalName $UPN -DisplayName $DisplayName -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -force) -CannotChangePassword $false -ChangePasswordAtLogon $False -Enabled $true -ProfilePath $ProfilePath -HomeDrive "U:" -HomeDirectory $HomeDirectory -ScriptPath $Script -Fax $Password -Path $ou
        #ecriture du login/password sur fichier
        Add-content -path $ListeLogin "$sc$DisplayName$sc,$sc$SamAccountName$sc,$sc$Password$sc,$scClasse$sc"
        #ajout de l'utilisateur en tant que membre de son groupe classe
        Add-ADGroupMember -Identity $User.classe -Members $SamAccountName
	    #ceration du repertoire perso de l'eleve
        New-Item $repertoire_doc –Type Directory
        #definition des securite du repertoire perso de l'eleve. seul lui y a acces ainsi que les profs intervenant dans sa classe.
        $acl = Get-Acl $repertoire_doc
        $acl.SetAccessRuleProtection($True, $False)
        $rule_acl = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrateurs","FullControl","ContainerInherit, ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($rule_acl)
        $rule_acl = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrateur","FullControl","ContainerInherit, ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($rule_acl)
        $rule_acl = New-Object System.Security.AccessControl.FileSystemAccessRule("system","FullControl","ContainerInherit, ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($rule_acl)
        $rule_acl = New-Object System.Security.AccessControl.FileSystemAccessRule($SamAccountName,"Modify,DeleteSubdirectoriesAndFiles", "ContainerInherit, ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($rule_acl)
        $rule_acl = New-Object System.Security.AccessControl.FileSystemAccessRule($GroupProf,"Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($rule_acl)
		Set-Acl $repertoire_doc $Acl
    }
    else
     <#   #pour le moment on ne fait rien car l'utilisateur plein existe
        #TODO : effectuer le depplacement de l'utilisateur dans sa nouvelle classe
        #pour cela conserver l'ancien fichier d'import et le renommer pour servir d'ancienne reference pour l'UO et les repertoires
    {"user exist, do nothing for this time. after we move it"
            $Ancien_groupe = 
            $Ancien_Repertoire = 

            remove-ADGroupMember -Identity $Anien_Groupe -Member $SamAccountName
	    set-Aduser -Identity $SamAccountName -UserPrincipalName $UPN -CannotChangePassword $false -ChangePasswordAtLogon $False -Enabled $True -ProfilePath $ProfilePath -HomeDrive "U:" -HomeDirectory $HomeDirectory -Fax $Password -passthru
       <#
        if ($reset_pwd -eq $true)
            {
            Set-adaccountpassword $SamAccountName -reset -newpassword (ConvertTo-SecureString -AsPlainText $password -Force)
            Add-content -path $ListeLogin "$sc$DisplayName$sc,$sc$SamAccountName$sc,$sc$Password$sc,$scClasse$sc"
            }
        else
        {} 
       #>
        #ajout de l'utilisateur en tant que membre de son groupe classe
        Add-ADGroupMember -Identity $User.classe -Members $SamAccountName
	    #deplacement du repertoire perso de l'eleve de son ancienne classse a la nouvelle
        move-item -path $Ancien_Repertoire -destination $repertoire_doc
        #definition des securite du repertoire perso de l'eleve. seul lui y a acces ainsi que les profs intervenant dans sa classe.
        $acl = Get-Acl $repertoire_doc
        $acl.SetAccessRuleProtection($True, $False)
        $rule_acl = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrateurs","FullControl","ContainerInherit, ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($rule_acl)
        $rule_acl = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrateur","FullControl","ContainerInherit, ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($rule_acl)
        $rule_acl = New-Object System.Security.AccessControl.FileSystemAccessRule("system","FullControl","ContainerInherit, ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($rule_acl)
        $rule_acl = New-Object System.Security.AccessControl.FileSystemAccessRule($SamAccountName,"Modify,DeleteSubdirectoriesAndFiles", "ContainerInherit, ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($rule_acl)
        $rule_acl = New-Object System.Security.AccessControl.FileSystemAccessRule($GroupProf,"Modify", "ContainerInherit, ObjectInherit", "None", "Allow")
        $acl.AddAccessRule($rule_acl)
		Set-Acl $repertoire_doc $Acl
    }#>
	{}
}
<#TODO mise en depot d'archive les ancien logins et leur repertoires resperctifs.
il restera a supprimer manuellement le tout une fois l'année demarrée et qu'ils ne sont plus nescessaires
cela pour permettre d'avoir acces aux contenu en cas de besoin

foreach ($User in $Users)
{
    #recherche de l'eleve  dans l'année precedente
    in $elevesN-1 get $elevesN-1.classe
    $ou = "OU="+ $User.classe + ",OU=" + $User.niveau + ",OU=ELEVES,OU=UTILISATEURS,DC=COLLEGE,DC=LOCAL"
	$SamAccountName =  $User.Prenom.substring(0,1)+$User.Nom
    $ProfilePathXP = "\\serveurcollege\Profils1$\"+$User.classe.substring(0,1)+"EME\"+$SamAccountName
    $ProfilePathW7 = "\\serveurcollege\Profils1$\"+$User.classe.substring(0,1)+"EME\"+$SamAccountName+".V2"
    $ProfilePathW10 = "\\serveurcollege\Profils1$\"+$User.classe.substring(0,1)+"EME\"+$SamAccountName+".V5"
    $ProfilePathW10_14393 = "\\serveurcollege\Profils1$\"+$User.classe.substring(0,1)+"EME\"+$SamAccountName+".V6"
	$Ancien_Repertoire = "D:\COLLEGE_STE_MARIE\ELEVES\NIVEAU_"+$User.classe.substring(0,1)+"EME\"+$User.classe+"\ELEVES\"+$SamAccountName
    #$GroupProf = "Profs "+$User.classe

    $repertoire_tmp_perso = "D:\COLLEGE_STE_MARIE\eleves_supprimes\perso\"+$SamAccountName
    $repertoire_tmp_profilXP = "D:\COLLEGE_STE_MARIE\eleves_supprimes\profil\"+$SamAccountName
    $repertoire_tmp_profilW7 = "D:\COLLEGE_STE_MARIE\eleves_supprimes\profil\"+$SamAccountName+".V2"
    $repertoire_tmp_profilW10 = "D:\COLLEGE_STE_MARIE\eleves_supprimes\profil\"+$SamAccountName+".V5"
    $repertoire_tmp_profilW10_14393 = "D:\COLLEGE_STE_MARIE\eleves_supprimes\profil\"+$SamAccountName+".V6"
    
    #deplacement dans l'OU eleve supprimmés
    move-Aduser $SamAccountName -ou "OU=eleves_supprimes,OU=UTILISATEURS,DC=COLLEGE,DC=LOCAL"
	#desactivation du compte
    set-ADUser $SamAccountName -Enabled $false
    #deplacement du repertoire perso dans repertoire tampon eleve
    move-item -path $Ancien_Repertoire -destination $repertoire_tmp_perso
	#deplacement du repertoire profil dans repertoire tampon eleve
    move-item -path $ProfilePathXP -destination $repertoire_tmp_profilXP
    if exist| move-item -path $ProfilePathW7 -destination $repertoire_tmp_profilW7
    if exist| move-item -path $ProfilePathW10 -destination $repertoire_tmp_profilW10
    if exist| move-item -path $ProfilePathW10_14393 -destination $repertoire_tmp_profilW10_14393
    
}#>
copy-Item -Path $fic_import -destination ".\Lycee_eleves_N-1.csv" -force