#	DIRCE Clean PC
#	
#	Sources From :
#
#	(c) Gauthier Millour
#	twitter.com/ptitgauth
#	gauthiermillour.fr
#
#	Windows 10 Decrapifier 18XX/19XX
#	By CSAND
#	Mar 01 2021
#	https://community.spiceworks.com/user-groups/windows-decrapifier-group
#
#	for GPO regedit changes see https://admx.help/?Category=Windows_10_2016
#
#
#
#PURPOSE: Eliminate much of the bloat that comes with Windows 10. Change many privacy settings to be off by default. Remove built-in advertising, Cortana, OneDrive, Cortana stuff (all optional). Disable some data collection.
#		  Clean up the start menu for new user accounts. Remove a bunch of pre-installed apps, or all of them (including the store). Create a more professional looking W10 experience. Changes some settings no longer
#         available via GPO for Professional edition.  All of this without breaking Windows.
#
#DISCLAIMER: Most of the changes are easily undone, but some like removing the store are difficult to undo.  You should use local/group policy to remove the store if you want.
#			   Read through the script to see what is disabled, and comment out anything you want to keep.

#	powershell.exe -ExecutionPolicy Bypass -File e:\DIRCE-decrap.ps1

#-------------------------------------------------------------------
#-----------------VARIABLES TO MODIFY-------------------------------
#-------------------------------------------------------------------

#Apps UWP

	#AppsToRemove are List of App to Remove and delete from new users. for reinstall, launch the store or ?????
	$AppsToRemove = @(
		"*Microsoft.549981C3F5F10*" #cortana
        "*bingfinance*"
        "*deezer*"
        "*MusicMakerJam*"
        "*Fitbit*"
        "*Plex*"
        "*PhototasticCollage*"
        "*BingSports*"
        "*cooking*"
        "*HiddenCityMysteryofShadows*"
        "*DragonManiaLegends*"
        "*king.com*"
        "*Disney*"
        "*Spotify*"
		"*MarchofEmpires*"
        "Facebook.Facebook"
        "*Twitter*"
        "Microsoft.BingNews"
		"Microsoft.BingWeather"
		"microsoft.windowscommunicationsapps"
        "Microsoft.Getstarted"
		"Microsoft.GetHelp"
        "Microsoft.OneConnect"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.Office.OneNote"
		"Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.MinecraftUWP"
		"Microsoft.MicrosoftOfficeHub"
        "Microsoft.MixedReality.Portal"
        "Microsoft.Print3D"
        "Microsoft.People"
        "Microsoft.SkypeApp"
        "Microsoft.WindowsMaps"
        "Microsoft.Zune*"
        "Microsoft.Messaging"
        "Microsoft.XboxApp"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.Xbox.TCUI"
        "Microsoft.XboxIdentityProvider"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxGamingOverlay"
		"Microsoft.XboxGameCallableUI"
        "*AutodeskSketchBook*"
        "*DolbyLaboratories*"
		"*LenovoSettingsforEnterprise*"
    )
	
	#GoodApps are Apps to keep but we less user to remove if he want
#Unused for now	$GoodApps =	"sticky|store|windows.photos|soundrecorder|mspaint|WindowsCamera|WindowsAlarms"

	#UnremoveApps are Apps to we not want less remove by user (nescesairy or replace old x86 Apps)
	$UnremoveApps = @(
		"*calculator*"
		"*ScreenSketch*"
	)


#Start Menu XML.
	#Place your XML like so:
	#	$StartLayourStr = @"
	#	<**YOUR START LAYOUT XML**>
	#	"@
	
			#Write-Host "***Setting empty start menu for new profiles...***"
	#Don't edit this. Creates empty start menu.
	$StartLayoutStr = @"
	<LayoutModificationTemplate Version="1" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification" 
		xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
		xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout"
		xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout"
		Version="1">
	  <LayoutOptions StartTileGroupCellWidth="6" />
	  <DefaultLayoutOverride>
		<StartLayoutCollection>
		  <defaultlayout:StartLayout GroupCellWidth="6" xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout">
			<start:Group Name="" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout">
			</start:Group>
		  </defaultlayout:StartLayout>
		</StartLayoutCollection>
	  </DefaultLayoutOverride>
	</LayoutModificationTemplate>
"@

	# exemple :
	# see : https://docs.microsoft.com/fr-fr/windows/configuration/configure-windows-10-taskbar
	#
	# <LayoutModificationTemplate Version="1" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
	  # <LayoutOptions StartTileGroupCellWidth="6" />
	  # <DefaultLayoutOverride>
		# <StartLayoutCollection>
		  # <defaultlayout:StartLayout GroupCellWidth="6" xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout">
			# <start:Group Name="" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout">
			  # <start:DesktopApplicationTile Size="2x2" Column="0" Row="0" DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\System Tools\File Explorer.lnk" />
			  # <start:DesktopApplicationTile Size="2x2" Column="2" Row="0" DesktopApplicationLinkPath="%ALLUSERSPROFILE%\Microsoft\Windows\Start Menu\Programs\Accessories\Snipping Tool.lnk" />
			  # <start:DesktopApplicationTile Size="2x2" Column="0" Row="2" DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\System Tools\Control Panel.lnk" />
			# </start:Group>
		  # </defaultlayout:StartLayout>
		# </StartLayoutCollection>
	  # </DefaultLayoutOverride>
	  	# <CustomTaskbarLayoutCollection>
			# <defaultlayout:TaskbarLayout>
				# <taskbar:TaskbarPinList>
				# </taskbar:TaskbarPinList>
			# </defaultlayout:TaskbarLayout>
		# </CustomTaskbarLayoutCollection>
	# </LayoutModificationTemplate>
# "@


#scheduled tasks
$DisTasks = "Microsoft Compatibility Appraiser","ProgramDataUpdater","Consolidator","KernelCeipTask","UsbCeip","Microsoft-Windows-DiskDiagnosticDataCollector","GatherNetworkInfo","QueueReporting"

#Services
$DisServices = "Diagtrack,WMPNetworkSvc,MapsBroker,SharedAccess,lfsvc"




#-------------------------------------------------------------------
#-----------------DON'T TOUCH THIS----------------------------------
#-------------------------------------------------------------------

	#SafeApps contains apps that shouldn't be removed, or just can't and cause errors
	$SafeApps = "AAD.brokerplugin|accountscontrol|apprep.chxapp|assignedaccess|asynctext|bioenrollment|capturepicker|cloudexperience|contentdelivery|desktopappinstaller|ecapp|edge|extension|getstarted|immersivecontrolpanel|lockapp|net.native|oobenet|parentalcontrols|PPIProjection|sechealth|secureas|shellexperience|startmenuexperience|vclibs|xaml|XGpuEject|PrintDialog"
	
#------------------------------------------------------------------
#----------------END OF VARIABLES----------------------------------
#------------------------------------------------------------------

#----------------FUNCTIONS-----------------------------------------

# TODO :
#
#	- Add Network profil settings if avalable
#		HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles
#		 Category 1
#		 ProfilName Metier
#
#	- Set Network icon as connected if firewall is on, and we have acces to interconnection
#		But a web server is nescessary on interconnection
#		http://www.win10.fr/windows10-detection-connexion-internet
#		KEY_LOCAL_MACHINE > SYSTEM > CurrentControlSet > Services > NLaSvc > Parameters > Internet
#
#   - unpin cortana and timeline from taskbar
#		

function UnPinTaskbar {
	Write-Host "***Detacher les applications de la barre des taches***" -ForegroundColor Magenta
			function UnPinFromTaskbar { param( [string]$appname )
			Write-Host "[INFO] Détacher l'application" $appname "de la barre des taches" -ForegroundColor Green
				Try {
					((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name -like "Désépingler de la b&arre des tâches" -OR $_.Name -like "Unpin from*"} | %{$_.DoIt()}
				} Catch {$a="b"}
			}
			
UnPinFromTaskbar "Courrier"
UnPinFromTaskbar "Microsoft Store"
UnPinFromTaskbar "Microsoft Edge"

}

Function removeAppxPackage {
	Write-Host "***Suppression des apps UWP inutiles dans un environnement DIRCE***" -ForegroundColor Magenta
			$i = 1
			foreach ($app in $AppsToRemove) {
				Write-Progress -PercentComplete ($i*100/$AppsToRemove.Count) -Activity "Suppression des Built-In Apps..."  -Status 'Progression...'
				$appExists = Get-AppxPackage $app | Where-Object {$_.Status -eq "Ok"}
				If ([string]::IsNullOrEmpty($appExists)) {
					}
				Else {
					Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers
					Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $app | Remove-AppxProvisionedPackage -Online
					}
				$i++
				Clear-Host
			}
			Start-Sleep 1
			if ($selectMain -ne '0') {
			main
			}
}

Function SetUnremoveAppx {
	Write-Host "***Definir certaines applications comme non desinstallable.***" -ForegroundColor Magenta
			$i = 1
			foreach ($app in $UnremoveApps) {
                Write-Host $app
				Get-AppxPackage -allusers | Where-Object PackageFamilyName -like $app | Set-NonRemovableAppsPolicy -Online -NonRemovable 1
			$i++
			}
			Get-NonRemovableAppsPolicy -online
			if ($selectMain -ne '0') {
				main
			}
}

Function selectListAppxPackage {
	Write-Host "***Affiche une liste des applications restantes pour suppression eventuelle***" -ForegroundColor Magenta
	$UnremoveApps = $UnremoveApps -join ','
	$UnremoveApps = $UnremoveApps.replace("*,*","|")
	$UnremoveApps = $UnremoveApps.replace("*","")
	$SafeApps = "$SafeApps|$UnremoveApps"
			Get-AppxProvisionedPackage -Online | where-object {$_.displayname -notmatch $SafeApps}|Out-GridView -PassThru | Remove-AppxProvisionedPackage -Online
			if ($selectMain -ne '0') {
			main
			}
}

Function restart {
    Write-Host -ForegroundColor Yellow -NoNewLine "Il est conseille de redemarrer votre systeme, souhaitez-vous le faire maintenant ? (o/n) : "
			While($True) {
				$selectRestart = Read-Host
				if ($selectRestart -eq 'o' -Or $selectRestart -eq 'O') {
					Write-Host -NoNewLine "Enregistrez votre travail et "
					pause
					Write-Host "Redemarrage dans 10 secondes..."
					Start-Process -FilePath "shutdown.exe" -ArgumentList "/r /t 10"
					Write-Host -ForegroundColor Red "Redemarrage..."
                    Stop-Transcript
					Start-Sleep 3
					exit
				}
				elseif ($selectRestart -eq 'n' -Or $selectRestart -eq 'N') {
					Write-Host "Retour au menu principal..."
					Start-Sleep 1
					main
				}
				else {
					restart
				}
			}
}

#Disable scheduled tasks
#Tasks: Various CEIP and information gathering/sending tasks.
Function DisableTasks {
    Write-Host "***Desactivation de certaines taches planifiées...***" -ForegroundColor Magenta
			Get-Scheduledtask $DisTasks -erroraction silentlycontinue | Disable-scheduledtask 
}

#Disable services
Function DisableServices {
    Write-Host "***Desactivation de certains services...***" -ForegroundColor Magenta
        #Diagnostics tracking WMP Network Sharing
			Get-Service $DisServices -erroraction silentlycontinue | stop-service -passthru | set-service -startuptype disabled
		#WAP Push Message Routing  NOTE Sysprep w/ Generalize WILL FAIL if you disable the DmwApPushService. Commented out by default.
			#Get-Service DmwApPushService -erroraction silentlycontinue | stop-service -passthru | set-service -startuptype disabled
		#Disable OneSync service - Used to sync various apps and settings if you enable that (contacts, etc). Commented out by default to not break functionality.
			#Get-Service OneSyncSvc | stop-service -passthru | set-service -startuptype disabled	
		#Disable xBox services - "xBox Game Monitoring Service" - XBGM - Can't be disabled (access denied)
			Get-Service XblAuthManager,XblGameSave,XboxNetApiSvc -erroraction silentlycontinue | stop-service -passthru | set-service -startuptype disabled
}

# Set or Disable optional features
Function OptionalFeatures {
	# Disable SMB V1
		Write-Host "Desactivation de SMB V1"
			Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol
			
			
}

#Registry change functions
Function setPrivacySettings {
	Write-Host "Debut des modifiactions du registre. activation de certaines GPO..." -ForegroundColor Magenta
	Start-Sleep 2
	
#Load default user hive
	Function loaddefaulthive {
		$matjazp72 = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList' Default).Default
		reg load "$reglocation" $matjazp72\ntuser.dat
	}

#Unload default user hive
	Function unloaddefaulthive {
		[gc]::collect()
		reg unload "$reglocation"
	}
#Cycle registry locations - 1st pass HKCU, 2nd pass default NTUSER.dat
#							3rd Pass HKLM or GPO
	Write-Host "***Application a l'utilisateur Courant >> HKCU...***" -ForegroundColor Darkgreen
    $reglocation = "HKCU"
		regsetuser
	Write-Host "***Modification du registre utlisateur par default >> NTUSER.DAT...***" -ForegroundColor Darkgreen
    $reglocation = "HKLM\AllProfile"
		loaddefaulthive; regsetuser; unloaddefaulthive
    $reglocation = $null
	Write-Host "***application au registre Machine >> HKLM...***" -ForegroundColor Darkgreen
		regsetmachine
    Write-Host "***Fin des modifications du registre***" -ForegroundColor Darkgreen
		if ($selectMain -ne '0') {
			pause
			main
		}

}



# $RegUCpath = "Registry::hkcu\Control Panel\Accessibility\Blind Access"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Flags -Type String -Value 0

#Set current and default user registry settings
Function RegSetUser {
    #Start menu suggestions
		Write-Host "[INFO] Ne pas afficher les suggestions dans le menu demarrer..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name SystemPaneSuggestionsEnabled -Type DWord -Value 0
	#Show suggested content in settings
		Write-Host "[INFO] Ne pas afficher les suggestions dans les parametres..." -ForegroundColor Green
		$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name SubscribedContent-338393Enabled -Type DWord -Value 0
		$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name SubscribedContent-353694Enabled -Type DWord -Value 0
	#Show suggestions occasionally
		Write-Host "[INFO] Ne pas afficher de suggestions occasionneles..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name SubscribedContent-338388Enabled -Type DWord -Value 0
	#Multitasking - Show suggestions in timeline
		Write-Host "[INFO] Ne pas afficher les suggestions dans la Timeline..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name SubscribedContent-353698Enabled -Type DWord -Value 0
    #Lockscreen suggestions, rotating pictures
		Write-Host "[INFO] Ne pas afficher de suggestions sur l'ecran de login..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name SoftLandingEnabled -Type DWord -Value 0
#		Write-Host "[INFO] Desactiver le changement dynamique de l'ecran de login..." -ForegroundColor Green
#			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name RotatingLockScreenEnabled -Type DWord -Value 0
#			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name RotatingLockScreenOverlayEnabled -Type DWord -Value 0
    #Preinstalled apps, Minecraft Twitter etc all that - still need a clean default start menu to fully eliminate
#		Write-Host "[INFO] Desactiver la preinstallation des apps UWP..." -ForegroundColor Green
#			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name PreInstalledAppsEnabled -Type DWord -Value 0
#			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name PreInstalledAppsEverEnabled -Type DWord -Value 0
#			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name OEMPreInstalledAppsEnabled -Type DWord -Value 0
    #MS shoehorning apps quietly into your profile
#		Write-Host "[INFO] Desactiver l'installation et update des apps UWP..." -ForegroundColor Green
#			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name SilentInstalledAppsEnabled -Type DWord -Value 0
#			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name ContentDeliveryAllowed -Type DWord -Value 0
#			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name SubscribedContentEnabled -Type DWord -Value 0
    #Ads in File Explorer
		Write-Host "[INFO] Desactiver la publicité dans l'explorateur..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name ShowSyncProviderNotifications -Type DWord -Value 0
	#Show me the Windows welcome experience after updates and occasionally
		Write-Host "[INFO] Desactiver l'ecran de presentation des nouveautes / suggestions..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name SubscribedContent-310093Enabled -Type DWord -Value 0
	#Get tips, tricks, suggestions as you use Windows
		Write-Host "[INFO] Desactiver les suggestions pendant l'utilisation..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name SubscribedContent-338389Enabled -Type DWord -Value 0

#Privacy Settings
	#Let websites provide local content by accessing language list - appears to reset during OOBE.
		Write-Host "[INFO] Empecher les sites d'acceder a la liste des langues..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\Control Panel\International\User Profile"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name HttpAcceptLanguageOptOut -Type DWord -Value 1
    #Ask for feedback
		Write-Host "[INFO] Desactivation des demandes d'envoi de commentaires a Microsoft..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Siuf\Rules"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name NumberOfSIUFInPeriod -Type DWord -Value 0											#
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Siuf\Rules"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name PeriodInNanoSeconds -Type DWord -Value 0
	#Let apps use advertising ID
		Write-Host "[INFO] Desactivation de l'identifiant publicitaire..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Enabled -Type DWord -Value 0
	#Let Windows track app launches to improve start and search results - includes run history
#		Write-Host "[INFO] Empecher Windows a suivre les demarrages d'applications..." -ForegroundColor Green
#			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Start_TrackProgs -Type DWord -Value 0
	#Tailored experiences - Diagnostics & Feedback settings
		Write-Host "[INFO] Desactivation de retour sur diagnostics..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name TailoredExperiencesWithDiagnosticDataEnabled -Type DWord -Value 0
	#Let apps on other devices open messages and apps on this device - Shared Experiences settings
		Write-Host "[INFO] Desactivation de parametres d'experience partagés..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\CDP"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name RomeSdkChannelUserAuthzPolicy -Type DWord -Value 0
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\CDP"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name CdpSessionUserAuthzPolicy -Type DWord -Value 0
	
#Speech Inking & Typing - comment out if you use the pen\stylus a lot
		Write-Host "[INFO] Desactivation du suivi pour les stylets..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Enabled -Type DWord -Value 0
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\InputPersonalization"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name RestrictImplicitTextCollection -Type DWord -Value 1
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\InputPersonalization"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name RestrictImplicitInkCollection -Type DWord -Value 1
		Write-Host "[INFO] Desactivation de l'apprentissage automatique de la saisie..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name HarvestContacts -Type DWord -Value 0
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Personalization\Settings"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name AcceptedPrivacyPolicy -Type DWord -Value 0
	#Improve inking & typing recognition
		Write-Host "[INFO] Desactivation dde la reconaissance d'ecriture avancée..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Input\TIPC"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Enabled -Type DWord -Value 0
	#Pen & Windows Ink - Show recommended app suggestions
		Write-Host "[INFO] Desactivation des suggestions d'applications pour l'ecriture manuscrite..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\PenWorkspace"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name PenWorkspaceAppSuggestionsEnabled -Type DWord -Value 0
	
#People
	#Show My People notifications
		Write-Host "[INFO] Desactivation des notifications de Contacts..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People\ShoulderTap"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name ShoulderTap -Type DWord -Value 0	#
	#Show My People app suggestions
		Write-Host "[INFO] Desactivation des suggestions de Contacts..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name SubscribedContent-314563Enabled -Type DWord -Value 0
	#People on Taskbar
		Write-Host "[INFO] retrait de l'icone contacts sur la barre des taches..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name PeopleBand -Type DWord -Value 0
	
# Vocal enhance
		Write-Host "[INFO] Desactivation de la reconnaissance vocale en ligne..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name HasAccepted -Type DWord -Value 0						#
	
# History Activity
		 Write-Host "[INFO] Desactivaton de l'historique de l'activite..." -ForegroundColor Green
			$RegUCpath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name EnableActivityFeed -Type DWord -Value 0
			$RegUCpath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name PublishUserActivities -Type DWord -Value 0
			$RegUCpath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\System"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name UploadUserActivities -Type DWord -Value 0
	

#App permissions user settings, these are all available from the settings menu
 
#App permissions
	#Location - see tablet settings
	#Camera
		Write-Host "[INFO] Desactivation des autorisations d'acces liees a la camera..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Type String -Value Deny
	#Microphone
		Write-Host "[INFO] Desactivation des autorisations d'acces liees au microphone..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Type String -Value Deny
	#Notifications - doesn't appear to work in 1803, setting hasn't been moved as of 1803 like most of the others
#			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{52079E78-A92B-413F-B213-E8FE35712E72}"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Type String -Value Deny
	#Account Info
		Write-Host "[INFO] Desactivation des autorisations d'acces liees aux informations sur le compte..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Type String -Value Deny
	#Contacts
		Write-Host "[INFO] Desactivation des autorisations d'acces liees aux contacts..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Type String -Value Deny				#######
	#Calendar
		Write-Host "[INFO] Desactivation des autorisations d'acces liees au calendrier..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Type String -Value Deny
	#Call
		Write-Host "[INFO] Desactivation des autorisations d'acces liees aux appels..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Value Deny
	#Call history
	    Write-Host "[INFO] Desactivation des autorisations d'acces liees a l'historique des appels..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Type String -Value Deny
	#Email
		Write-Host "[INFO] Desactivation des autorisations d'acces liees aux couriers electroniques..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Type String -Value Deny
	#Tasks
		Write-Host "[INFO] Desactivation des autorisations d'acces liees aux taches de l'utilisateur..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Type String -Value Deny
	#TXT/MMS
		Write-Host "[INFO] Desactivation des autorisations d'acces liees a la messagerie..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Type String -Value Deny
	#Radios
		Write-Host "[INFO] Desactivation des autorisations d'acces liees aux Radios..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Value Deny
	#bluetoothSync
	    Write-Host "[INFO] Desactivation des autorisations d'acces liees a la synchro bluetooth..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Value Deny
	#Other Devices - reset during OOBE
		Write-Host "[INFO] Desactivation des autorisations d'acces liees aux autres equipements..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\LooselyCoupled"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Type String -Value Deny
	#Cellular Data
		Write-Host "[INFO] Desactivation des autorisations d'acces liees aux données cellulaires..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\cellularData"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Type String -Value Deny
	#Allow apps to run in background global setting - seems to reset during OOBE
#		Write-Host "[INFO] Desactivation des applications en arriere-plan..." -ForegroundColor Green
#			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name GlobalUserDisabled -Type DWord -Value 1
#			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name BackgroundAppGlobalToggle -Type DWord -Value 0
	#App Diagnostics
#		Write-Host "[INFO] Desactivation des diagonistiques d'applications..." -ForegroundColor Green
#			$RegUCpath = "Registry::$reglocation\SOFTWARE\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Type String -Value Deny
	#My Documents
#		Write-Host "[INFO] Desactivation des autorisations d'acces liees aux documents presents sur l'ordinateur..." -ForegroundColor Green
#			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Type String -Value Deny
	#My Pictures
#		Write-Host "[INFO] Desactivation des autorisations d'acces liees aux images presents sur l'ordinateur..." -ForegroundColor Green
#			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Type String -Value Deny
	#My Videos
#		Write-Host "[INFO] Desactivation des autorisations d'acces liees aux videos presents sur l'ordinateur..." -ForegroundColor Green
#			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Type String -Value Deny
	#File System
#		Write-Host "[INFO] Desactivation des autorisations d'acces liees au systeme de fichiers de l'ordinateur..." -ForegroundColor Green
#			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Type String -Value Deny
		
#Tablet Settings
	#Deny access to location and sensors
		Write-Host "[INFO] Desactivation des autorisations d'acces liees aux capteurs de l'appareil..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Permissions\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name SensorPermissionState -Type DWord -Value 0
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Type String -Value Deny
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\{E6AD100E-5F4E-44CD-BE0F-2265D88D14F5}"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Type String -Value Deny
		Write-Host "[INFO] Desactivation des autorisations d'acces liees a la localisation..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Type String -Value Deny					#######

#Disable Cortana and Bing search user settings
		Write-Host "[INFO] Desactivation de Cortana..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name CortanaEnabled -Type DWord -Value 0
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name CanCortanaBeEnabled -Type DWord -Value 0
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name DeviceHistoryEnabled -Type DWord -Value 0
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name CortanaConsent -Type DWord -Value 0
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name CortanaInAmbientMode -Type DWord -Value 0
	#Disable Cortana on lock screen
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Speech_OneCore\Preferences"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name VoiceActivationEnableAboveLockscreen -Type DWord -Value 0
	#Disable Cortana search history
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name HistoryViewEnabled -Type DWord -Value 0
		
#Game settings
	#Disable Game DVR
		Write-Host "[INFO] Desactivation de parametres de jeux..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\System\GameConfigStore"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name GameDVR_Enabled -Type DWord -Value 0


#Other Settings

	#Ease of Acces Settings and shortcuts
		Write-Host "[INFO] Modification des parametres d'accesibilité..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\Control Panel\Accessibility\On"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name On -Type DWord -Value 0
		Write-Host "[INFO] Desactivation de la Loupe..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\Control Panel\Accessibility\Blind Access"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Flags -Type String -Value 0
		Write-Host "[INFO] Desactivation du Contraste élevé..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\Control Panel\Accessibility\HighContrast"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Flags -Type String -Value 4194
		Write-Host "[INFO] Desactivation du soulignement des raccourcis clavier..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\Control Panel\Accessibility\Keyboard Preference"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name On -Type String -Value 0
		Write-Host "[INFO] Desactivation des touches filtres..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\Control Panel\Accessibility\Keyboard Response"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Flags -Type String -Value 2
			$RegUCpath = "Registry::$reglocation\Control Panel\Accessibility\Keyboard Response"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name 'Last Valid Wait' -Type DWord -Value 1000
		Write-Host "[INFO] Desactivation des touches Souris..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\Control Panel\Accessibility\Keyboard Response"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Flags -Type String -Value 34
		Write-Host "[INFO] Desactivation des Alertes Visuelles..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\Control Panel\Accessibility\ShowSounds"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name On -Type String -Value 0		
			$RegUCpath = "Registry::$reglocation\Control Panel\Accessibility\SoundSentry"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Flags -Type String -Value 2
			$RegUCpath = "Registry::$reglocation\Control Panel\Accessibility\SoundSentry"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name WindowsEffect -Type String -Value 1
			$RegUCpath = "Registry::$reglocation\Control Panel\Accessibility\SoundSentry"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name FSTextEffect -Type String -Value 0
			$RegUCpath = "Registry::$reglocation\Control Panel\Accessibility\SoundSentry"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name TextEffect -Type String -Value 0
		Write-Host "[INFO] Desactivation des Touches Remanentes..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\Control Panel\Accessibility\StickyKeys"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Flags -Type String -Value 482
		Write-Host "[INFO] Reglage du delai des notifications..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\Control Panel\Accessibility\TimeOut"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Flags -Type String -Value 2
			$RegUCpath = "Registry::$reglocation\Control Panel\Accessibility\TimeOut"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name TimeToWait -Type String -Value 300000
		Write-Host "[INFO] Desactivation des Touches Bascules..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\Control Panel\Accessibility\ToggleKeys"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Flags -Type String -Value 58

	#Use Autoplay for all media and devices
		Write-Host "[INFO] Desactivation de la lecture automatique..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name DisableAutoplay -Type DWord -Value 1
			
	#Taskbar search, personal preference. 0 = no search, 1 = search icon, 2 = search bar
		Write-Host "[INFO] suppression de l'icone recherche sur la barre des taches..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name SearchboxTaskbarMode -Type DWord -Value 0
			
	#Allow search to use location if it's enabled
		Write-Host "[INFO] Desactivation de l'utilisation de la localisation dans les recherches..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name AllowSearchToUseLocation -Type DWord -Value 0
			
	#Do not track - Edge
		Write-Host "[INFO] Activer DO Not Track..." -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\Main"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name DoNotTrack -Type DWord -Value 1
	#Do not track - IE
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Internet Explorer\Main"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name DoNotTrack -Type DWord -Value 1
			
	#Start Explorer on "This PC"
		Write-Host "[INFO] Demarrage de l'explorateur dans 'Ce PC' par defaut..."
			$RegUCpath = "Registry::$reglocation\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name LaunchTo -Type DWord -Value 1

	#Show files extentions
		Write-Host "[INFO] Activation de l'affichage des extensions de fichiers..."
			$RegUCpath = "Registry::$reglocation\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name HideFileExt -Type DWord -Value 0
			
	#Disable explorer Cache
#		Write-Host "[INFO] Desactivation du cache de l'explorateur..."
#		 	$RegUCpath = "Registry::$reglocation\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Start_TrackDocs -Type DWord -Value 0

	#Diable internet search on start menu
		Write-Host "[INFO] Desactivation de la recherche par Internet dans le menu demarrer" -ForegroundColor Green
			$RegUCpath = "Registry::$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name BingSearchEnabled -PropertyType DWord -Value 0
		

#End user registry settings
}

#Set local machine settings and local group policies    
Function RegSetMachine {
#--Local GP settings--   CONVERT THESE TO HKCU / DEFAULT / HKLM WHERE POSSIBLE
    #Can be adjusted in GPedit.msc in Pro+ editions.
    #Local Policy\Computer Config\Admin Templates\Windows Components			
    #
	# see for more info https://admx.help/?Category=Windows_10_2016
	#
	#
	#/Application Compatibility
    #Turn off Application Telemetry
		Write-Host "[INFO] [GPO] Desactivation de la Telemértie" -ForegroundColor Green
			$RegUCpath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name AITEnable -Type DWord -Value 0			
    #Turn off inventory collector
		Write-Host "[INFO] [GPO] Desactivation de la collecte de Telemértie" -ForegroundColor Green
			$RegUCpath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name DisableInventory -Type DWord -Value 1

    #/Cloud Content			
    #Turn off Consumer Experiences	- Enterprise only (for Pro, HKCU settings and start menu cleanup achieve same result)
		Write-Host "[INFO] [GPO] [ENTREPRISE] Desactivation des fonctionalités d'experience utilisateur" -ForegroundColor Green
			$RegUCpath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name DisableWindowsConsumerFeatures -Type DWord -Value 1
	#Turn off all spotlight features
#		Write-Host "[INFO] [GPO] Desactivation de windows Spotlight" -ForegroundColor Green
#			$RegUCpath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name DisableWindowsSpotlightFeatures -Type DWord -Value 1  

    #/Data Collection and Preview Builds			
    #Set Telemetry to off (switches to 1:basic for W10Pro and lower)
		Write-Host "[INFO] [GPO] Definition des parametres de diagnostiques sur De Base..." -ForegroundColor Green	
			$RegUCpath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name AllowTelemetry -Type DWord -Value 0
    #Disable pre-release features and settings	
		Write-Host "[INFO] [GPO] Desactivation des Builds Developpeurs" -ForegroundColor Green
			$RegUCpath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name EnableConfigFlighting -Type DWord -Value 0
    #Do not show feedback notifications
		Write-Host "[INFO] [GPO] Desactivation des demandes d'envoie de commentaires a Microsoft..." -ForegroundColor Green
			$RegUCpath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name DoNotShowFeedbackNotifications -Type DWord -Value 1

    #/Store
    #Disable all apps from store, commented out by default as it will break the store
#		Write-Host "[INFO] [GPO] Desactivation du store" -ForegroundColor Green
#			$RegUCpath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\WindowsStore"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name DisableStoreApps -Type DWord -Value 1		
    #Turn off Store, left disabled by default
#			$RegUCpath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\WindowsStore"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name RemoveWindowsStore -Type DWord -Value 1

    #/Sync your settings - commented out by default to keep functionality of sync service		
    #Do not sync (anything)
		Write-Host "[INFO] [GPO] Desactivation de la syncronisation des parametres" -ForegroundColor Green
			$RegUCpath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name DisableSettingSync -Type DWord -Value 2
    #Disallow users to override this
		Write-Host "[INFO] [GPO] Empecher les utilisateurs d'activer la synchronisation des parametres" -ForegroundColor Green
			$RegUCpath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name DisableSettingSyncUserOverride -Type DWord -Value 1
	
	#Add "Run as different user" to context menu
#		Write-Host "[INFO] [GPO] Ajout de 'executer en tant que...' " -ForegroundColor Green
#			$RegUCpath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name ShowRunasDifferentuserinStart -Type DWord -Value 1
	
	#Disable "Meet Now" taskbar button
		Write-Host "[INFO] [GPO] suppression de l'icone 'démarrer une réunion' dans la barre des taches " -ForegroundColor Green
			$RegUCpath = "Registry::HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name HideSCAMeetNow -Type DWord -Value 1
	
	#!!!None of these effective anymore in 1803!!! Now handled by HKCU settings
    #Disallow web search from desktop search			
			#$RegUCpath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name DisableWebSearch -Type DWord -Value 1
    #Don't search the web or display web results in search			
			#$RegUCpath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name ConnectedSearchUseWeb -Type DWord -Value 0
	#Don't allow search to use location
			#$RegUCpath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name AllowSearchToUseLocation -Type DWord -Value 0

    #/Windows Update			
    #Turn off featured SOFTWARE notifications through Windows Update
#		Write-Host "[INFO] [GPO] Desactivation de Windows Update...' " -ForegroundColor Green
#			$RegUCpath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name EnableFeaturedSoftware -Type DWord -Value 0
    #add recomanded update to windows update
		Write-Host "[INFO] [GPO] ajout des mises a jour recommmandées...' " -ForegroundColor Green
			$RegUCpath = "Registry::HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name IncludeRecommendedUpdates -Type DWord -Value 1

	#Disable CEIP. GP setting at: Computer Config\Admin Templates\System\Internet Communication Managemen\Internet Communication settings
		Write-Host "[INFO] [GPO] désactive le Programme d’amélioration de l’expérience utilisateur..." -ForegroundColor Green
			$RegUCpath = "Registry::HKLM\SOFTWARE\Microsoft\SQMClient\Windows"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name CEIPEnable -Type DWord -Value 0

	#Disable Cortana
    #Cortana local GP - Computer Config\Admin Templates\Windows Components\Search			
    #Disallow Cortana	
		Write-Host "[INFO] [GPO] Desactivation de Cortana..." -ForegroundColor Green
			$RegUCpath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name AllowCortana -Type DWord -Value 0
    #Disallow Cortana on lock screen - seems pointless with above setting, may be deprecated, covered by HKCU anyways
		Write-Host "[INFO] [GPO] Ne Pas Activer Cortana sur l'ecran de login..." -ForegroundColor Green
			$RegUCpath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name AllowCortanaAboveLock -Type DWord -Value 0
			
	#Edge
	#Disable Edge Pre-launch
		Write-Host " [INFO] [GPO] Désactivation du prechargement d'Edge. libere de la RAM..." -ForegroundColor Green
			$RegUCpath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name AllowPrelaunch -Type DWord -Value 0
			$RegUCpath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name AllowTabPreloading -Type DWord -Value 0

#--Non Local GP Settings--
    #Delivery Optimization settings - sets to 1 for LAN only, change to 0 for off
		Write-Host "[INFO] Configuration de la distribution partége des mises a jour sur reseau local uniquement...' " -ForegroundColor Green
			$RegUCpath = "Registry::HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name DownloadMode -Type DWord -Value 1
			$RegUCpath = "Registry::HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name DODownloadMode -Type DWord -Value 1
			$RegUCpath = "Registry::HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name DownloadMode -Type DWord -Value 1
	
    #Disabling advertising info and device metadata collection for this machine
		Write-Host "[INFO] Desactivation de l'identifiant publicitaire..." -ForegroundColor Green
			$RegUCpath = "Registry::HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Enabled -Type DWord -Value 0
			$RegUCpath = "Registry::HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name PreventDeviceMetadataFromNetwork -Type DWord -Value 1
			$RegUCpath = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name DisabledByGroupPolicy -Type DWord -Value 1

	#Turn off automatic download/install of store app updates
#		Write-Host "[INFO] Desactivation de l'installation / update Automatique des apps depuis le store..." -ForegroundColor Green
#			$RegUCpath = "Registry::HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name AutoDownload -Type DWord -Value 2
	
	#Prevent using sign-in info to automatically finish setting up after an update
#		Write-Host "[INFO] Desactivation d' l'auto connexion apres une update pour finalisation..." -ForegroundColor Green
#			$RegUCpath = "Registry::HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name ARSOUserConsent -Type DWord -Value 0
	
    #Prevent apps on other devices from opening apps on this one - disables phone pairing
		Write-Host "[INFO] Desactivation de la possibilté a d'autres periphérique d'ouvrir des applications... Désactive la possibilité d'associer un téléphone" -ForegroundColor Green
			$RegUCpath = "Registry::HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name UserAuthPolicy -Type DWord -Value 0
    
    #Enable diagnostic data viewer
#		Write-Host "[INFO] Activation du visionneur de diagnostics..." -ForegroundColor Green
#			$RegUCpath = "Registry::HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\EventTranscriptKey"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name EnableEventTranscript -Type DWord -Value 1
	
	#Disable Edge desktop shortcut
		Write-Host "[INFO] Desactive le forcage du raccourci d'EDGE..." -ForegroundColor Green
			$RegUCpath = "Registry::HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name DisableEdgeDesktopShortcutCreation -Type DWord -Value 1
	
	#Filter web content through smartscreen. Left enabled
		Write-Host "[INFO] Desactive le Filtrage du contenu web..." -ForegroundColor Green by default.
			$RegUCpath = "Registry::HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name EnableWebContentEvaluation -Type DWord -Value 0
	
	# HKEY_LOCAL_MACHINE/System/CurrentControlSet/Services/LanManWorkstation
	#HKEY_LOCAL_MACHINE/System/CurrentControlSet/Services/Browser
	#HKEY_LOCAL_MACHINE/System/CurrentControlSet/Services/LanManServer.
	#netbios
	#SMB over DNS : 445
	
#Tablet Settings
	#Turn off location - global
		Write-Host "[INFO] désactive la localisation de la machine..." -ForegroundColor Green
			$RegUCpath = "Registry::HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Value -Type String -Value Deny
	
#Game settings
	#Disable Game Monitoring Service
		Write-Host "[INFO] désactive le Service de monitoring Xbox..." -ForegroundColor Green
			$RegUCpath = "Registry::HKLM\SYSTEM\CurrentControlSet\Services\xbgm"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name Start -Type DWord -Value 4
	#GameDVR local GP - Computer Config\Admin Templates\Windows Components\Windows Game Recording and Broadcasting
		Write-Host "[INFO] désactive le composant d'enregistrement Xbox..." -ForegroundColor Green
			$RegUCpath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name AllowGameDVR -Type DWord -Value 0

	
#End machine registry settings
}

Function RemoveOneDrive {
		Write-Output "Uninstalling OneDrive. Please wait."
	#Uninstalling
			Stop-Process -Name "OneDrive*"
			Start-Sleep 2
			$OneDrive = "$env:SYSTEMROOT\SysWOW64\OneDriveSetup.exe"; if(-not(Test-Path $OneDrive)) {$OneDrive = "$env:SYSTEMROOT\System32\OneDriveSetup.exe"}
			Start-Process "$OneDrive /uninstall" -NoNewWindow -Wait
			Start-Sleep 2
		Write-Output "Stopping explorer"
			Start-Sleep 1
			.\taskkill.exe /F /IM explorer.exe
			Start-Sleep 3
	#Delete Folders
		Write-Output "Removing leftover files"
			Remove-Item "$env:USERPROFILE\OneDrive" -Force -Recurse
			Remove-Item "$env:LOCALAPPDATA\Microsoft\OneDrive" -Force -Recurse
			Remove-Item "$env:PROGRAMDATA\Microsoft OneDrive" -Force -Recurse
			If (Test-Path "$env:SYSTEMDRIVE\OneDriveTemp") {
				Remove-Item "$env:SYSTEMDRIVE\OneDriveTemp" -Force -Recurse
			}
	#Registry
		Write-Output "Removing OneDrive from windows explorer"
	#Disable OneDrive startup run user settings
			$RegUCpath = "Registry::HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name OneDrive -Type Binary -Value 0300000021B9DEB396D7D001
	#Detach OneDrive from explorer sidebar
			$RegUCpath = "Registry::HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name System.IsPinnedToNameSpaceTree -Type DWord -Value 0
			$RegUCpath = "Registry::HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name System.IsPinnedToNameSpaceTree -Type DWord -Value 0
	#Prevent usage of OneDrive local GP - Computer Config\Admin Templates\Windows Components\OneDrive
			$RegUCpath = "Registry::HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive"; if(-not(Test-Path $RegUCpath)) {New-Item $RegUCpath -Force} ; set-ItemProperty -path $RegUCpath -Name DisableFileSyncNGSC -Type DWord -Value 1
	#Removing run hook for new users
		Write-Output "Removing run hook for new users"
			$loaddefaulthive = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList' Default).Default
			reg load "hku\Default" $loaddefaulthive\ntuser.dat
			reg delete "HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f
			reg unload "hku\Default"
	#Removing startmenu entry
		Write-Output "Removing startmenu entry"
			Remove-Item -Force -ErrorAction SilentlyContinue "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"
	#Removing scheduled task
		Write-Output "Removing scheduled task"
			Get-ScheduledTask "OneDrive*" -erroraction silentlycontinue | Unregister-ScheduledTask -Confirm:$false
		Write-Output "Restarting Explorer that was shut down before."
			Start explorer.exe -NoNewWindow
	if ($selectMain -ne '0') {
            pause
			main
        }
}

#Clean up the default start menu    
Function ClearStartMenu {
     
		Write-Host "***Setting clean start menu for new profiles...***"
#Custom start layout XML near the top of the script.
        add-content $Env:TEMP\startlayout.xml $StartLayoutStr
        import-startlayout -layoutpath $Env:TEMP\startlayout.xml -mountpath $Env:SYSTEMDRIVE\
        remove-item $Env:TEMP\startlayout.xml
}

#Restitution des Appx
#Get-AppxPackage -AllUsers| Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}

#----------------MAIN MENU-----------------------------------------

Function main {
    #Clear-Host
    Write-Host -ForegroundColor Green "==== MENU ===="
	Write-Host -ForegroundColor Cyan "[0] - Faire une passe globale"
    Write-Host -ForegroundColor Cyan "[1] - Supprimer les applications integrees"
    Write-Host -ForegroundColor Cyan "[2] - Definir les parametres de confidentialites"
    Write-Host -ForegroundColor Cyan "[3] - Supprimùer One Drive"
    #Write-Host -ForegroundColor Cyan "[4] - Configurer l'explorateur Windows `n(demarrage dans 'Ce PC', desactivation du cache, affichage des extensions, activation du volet details)"
    #Write-Host -ForegroundColor Cyan "[5] - Ameliorer la recherche Windows"
    Write-Host -ForegroundColor Cyan "[6] - Lister et Supprimer les applications integrees (selectionner pour supprimer)"
    Write-Host -ForegroundColor Cyan "[q/Q] - Quitter"
    Write-Host ""
    Write-Host -ForegroundColor Yellow -NoNewLine "Que voulez-vous faire ? : "
    While($True) {
        $selectMain = Read-Host
		if ($selectMain -eq '0') {
			UnPinTaskbar
            removeAppxPackage
			SetUnremoveAppx
			selectListAppxPackage
			DisableTasks
			DisableServices
OptionalFeatures
			setPrivacySettings
			RemoveOneDrive
			ClearStartMenu
			restart
        }
        if ($selectMain -eq '1') {
            UnPinTaskbar
            removeAppxPackage
			SetUnremoveAppx
			selectListAppxPackage
        } 
        elseif ($selectMain -eq '2')  {
            setPrivacySettings
        }
        elseif ($selectMain -eq '3') {
            RemoveOneDrive
        }
        # elseif ($selectMain -eq '4') {
            # explorerDefaultStart
        # }
        # elseif ($selectMain -eq '5') {
            # enhanceSearch
        # }
        elseif ($selectMain -eq '6') {
            selectListAppxPackage
        }
        elseif ($selectMain -eq 'q' -Or $selectMain -eq 'Q') {
            Stop-Transcript
            Clear-Host
            exit
        }
        else {
            main
        }
    }
}

Start-Transcript -IncludeInvocationHeader -OutputDirectory $env:SystemDrive\temp
main