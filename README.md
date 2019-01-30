# SDP-Module
Manage Engine - Service Desk Plus Powershell Module


SDP-Dynamic_Module
Utilising dynamic paramiters (using direct call to SQL DB) to provide values based on your install and customisation.



SDP-API
Script is for use in custom triggers (API calls) SDP passes information via $COMPLETE_JSON_FILE. This script is more steamlined and faster for bulk use.


Running this script will look something like the below.
cmd /c start /wait powershell.exe -WindowStyle Hidden -command "& { . D:\ManageEngine\ServiceDesk\integration\custom_scripts\SDP-API.ps1; Add-APINotes $COMPLETE_JSON_FILE *>> C:\SDP\Logs\Log.txt}"




SDP\SDP_Information.csv
File contains your Production and Sandbox SQL DB Path, Server URL, APIKey. This allows everyone to provide custom values instead of having to pass them through each time. 





Currently Testing on Version 9.4 Build 9425 (Version 10 is currently avalible but I do not have access yet)
