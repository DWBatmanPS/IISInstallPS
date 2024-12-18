##Install IIS
Add-WindowsFeature Web-Server

##Loading powershell modules
Import-Module -Name WebAdministration

##Begin basic site configuration
Remove-IISSite -Name "Default Web Site" -Confirm:$false
New-IISSite -Name "LabSite" -BindingInformation "*:80:" -PhysicalPath "$env:systemdrive\inetpub\wwwroot"
Set-Content -Path "$env:systemdrive\inetpub\wwwroot\Default.htm" -Value "Hello World from host $($env:computername) !"

##Configure Logging
$logdir = '%SystemDrive%\inetpub\logs\LogFiles'
Set-ItemProperty `
    -Path 'IIS:\Sites\LabSite' `
    -Name Logfile.enabled `
    -Value $true
Invoke-Expression "& '$env:WINDIR\system32\inetsrv\appcmd.exe' unlock config -section:system.applicationHost/log"
Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.applicationHost/sites/site[@name='LabSite']/logFile/customFields" -name "." -value @{logFieldName='Content-Length';sourceName='Content-Length';sourceType='RequestHeader'}
Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.applicationHost/sites/site[@name='LabSite']/logFile/customFields" -name "." -value @{logFieldName='Host';sourceName='Host';sourceType='RequestHeader'}
Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.applicationHost/sites/site[@name='LabSite']/logFile/customFields" -name "." -value @{logFieldName='User-Agent';sourceName='UserAgent';sourceType='RequestHeader'}
Add-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.applicationHost/sites/site[@name='LabSite']/logFile/customFields" -name "." -value @{logFieldName='X-Forwarded-For';sourceName='X-Forwarded-For';sourceType='RequestHeader'}
Set-WebConfigurationProperty "/system.applicationHost/sites/siteDefaults" -name logfile.directory -value $logdir

##Lock IIS COnfig down.
Invoke-Expression "& '$env:WINDIR\system32\inetsrv\appcmd.exe' lock config -section:system.applicationHost/log"
