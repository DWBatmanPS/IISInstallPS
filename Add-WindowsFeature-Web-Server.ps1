Add-WindowsFeature Web-Server
Import-Module -Name WebAdministration
Remove-IISSite -Name "Default Web Site" -Confirm:$false
New-IISSite -Name "LabSite" -BindingInformation "*:80:" -PhysicalPath "$env:systemdrive\inetpub\wwwroot"
Set-Content -Path "$env:systemdrive\inetpub\wwwroot\Default.htm" -Value "Hello World from host $($env:computername) !"
$logdir = '%SystemDrive%\inetpub\logs\LogFiles'
Set-ItemProperty `
    -Path 'IIS:\Sites\LabSite' `
    -Name Logfile.enabled `
    -Value $true
Invoke-Expression "& '$env:WINDIR\system32\inetsrv\appcmd.exe' unlock config -section:system.applicationHost/log"
Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.applicationHost/sites/site[@name='LabSite']/logFile/customFields" -name "." -value @{logFieldName='Content-Length';sourceName='Content-Length';sourceType='RequestHeader'}
Set-WebConfigurationProperty "/system.applicationHost/sites/siteDefaults" -name logfile.directory -value $logdir
Invoke-Expression "& '$env:WINDIR\system32\inetsrv\appcmd.exe' lock config -section:system.applicationHost/log"