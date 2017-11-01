@echo on

cd c:\gi\sauvegarde	

call avantsauv.bat

powershell -command "&{%CD%\sauvegarde.ps1}"

call apressauv.bat