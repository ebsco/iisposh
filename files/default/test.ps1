$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
. $scriptPath\iis_web_tools.ps1

$results = New-Pool -name "demopool" -myhash @{"recycling.periodicRestart.privatememory"=4 ; "processmodel.maxprocesses"=3 ; "managedPipeLineMode"="Integrated" ; "managedRunTimeVersion"="v2.0" ; "processModel.IdentityType"="NetworkService" ; "autostart"="True" ; "processmodel.pingingenabled"="true" ; "enable32BitAppOnWin64"="false" ; "processmodel.username"="" ; "processmodel.password"="" ; "recycling.logEventOnRecycle"="Time,Requests,IsapiUnhealthy,OnDemand,ConfigChange" }
write-host "--------------------------------"
Pool-Exists -name "demopool"
write-host "--------------------------------"
$results = Check-PoolProperties -name "DemoPool" -myhash @{"recycling.periodicRestart.privatememory"=4 ; "processmodel.maxprocesses"=3 ; "managedPipeLineMode"="Integrated" ; "managedRunTimeVersion"="v2.0" ; "processModel.IdentityType"="NetworkService" ; "autostart"="True" ; "processmodel.pingingenabled"="true" ; "enable32BitAppOnWin64"="false" ; "processmodel.username"="" ; "processmodel.password"="" ; "recycling.logEventOnRecycle"="Time,Requests,IsapiUnhealthy,OnDemand,ConfigChange" }
#return; #Found a bug in false compared to False
write-host "--------------------------------"
Get-RunningState -name "demopool" -pool
write-host "--------------------------------"
Config-Pool -name "demopool" -myhash @{}
write-host "--------------------------------"
Change-State -name "demopool" -pool -start
write-host "--------------------------------"
Change-State -name "demopool" -pool -stop
write-host "--------------------------------"
Restart-Webobject -name "demopool" -pool


write-host "--------------------------------"
write-host "--------------------------------"
write-host "--------------------------------"
New-Iisweb -name "Demosite" -myhash @{"applicationPool"="DemoPool"; "physicalPath"="c:/temp"; "ServerAutoStart"="True";"logfile.logformat"="W3C"; "logfile.directory"="c:\weblogs"; "limits.connectionTimeout"="00:03:00"; "logfile.logExtFileFlags"="Date,Time,ClientIP,ServerIP,Method,UriStem,UriQuery,HttpStatus,BytesSent,TimeTaken,UserAgent"} -bindings @(,("http", "9092", "", "*")) 
write-host "--------------------------------"
Configure-Website -name "Demosite" -myhash @{"applicationPool"="DemoPool"; "physicalPath"="c:/temp"; "ServerAutoStart"="True";"logfile.logformat"="W3C"; "logfile.directory"="c:\weblogs"; "limits.connectionTimeout"="00:03:00"; "logfile.logExtFileFlags"="Date,Time,ClientIP,ServerIP,Method,UriStem,UriQuery,HttpStatus,BytesSent,TimeTaken,UserAgent"} -bindings @(,("http", "9092", "", "*")) 
write-host "--------------------------------"
Check-WebSiteProperties -name "Demosite" -myhash @{"applicationPool"="DemoPool"; "physicalPath"="c:/temp"; "ServerAutoStart"="True";"logfile.logformat"="W3C"; "logfile.directory"="c:\weblogs"; "limits.connectionTimeout"="00:03:00"; "logfile.logExtFileFlags"="Date,Time,ClientIP,ServerIP,Method,UriStem,UriQuery,HttpStatus,BytesSent,TimeTaken,UserAgent"} -bindings @() 

write-host "--------------------------------"
Check-WebSiteProperties -name "Demosite" -myhash @{"applicationPool"="DemoPool"; "physicalPath"="c:/temp"; "ServerAutoStart"="True";"logfile.logformat"="W3C"; "logfile.directory"="c:\weblogs"; "limits.connectionTimeout"="00:03:00"; "logfile.logExtFileFlags"="Date,Time,ClientIP,ServerIP,Method,UriStem,UriQuery,HttpStatus,BytesSent,TimeTaken,UserAgent"} -bindings @(,("http", "9092", "", "*")) 
write-host "--------------------------------"
Restart-Webobject -name "Demosite" -website
write-host "--------------------------------"
New-Iisweb -name "Demosite2" -myhash @{"applicationPool"="DemoPool"; "physicalPath"="c:\temp"; "ServerAutoStart"="True";"logfile.logformat"="W3C"; "logfile.directory"="c:\weblogs"; "limits.connectionTimeout"="00:03:00"; "logfile.logExtFileFlags"="Date,Time,ClientIP,ServerIP,Method,UriStem,UriQuery,HttpStatus,BytesSent,TimeTaken,UserAgent"} -bindings @(("http", "9094", "", "*"),("http", "9093", "", "*")) 
New-Iisweb -name "Demosite3" -myhash @{"applicationPool"="DemoPool"; "physicalPath"="c:\temp"; "ServerAutoStart"="True";"logfile.logformat"="W3C"; "logfile.directory"="c:\weblogs"; "limits.connectionTimeout"="00:03:00"; "logfile.logExtFileFlags"="Date,Time,ClientIP,ServerIP,Method,UriStem,UriQuery,HttpStatus,BytesSent,TimeTaken,UserAgent"} -bindings @() 
write-host "--------------------------------"
Change-State -name "Demosite2" -website -start
write-host "--------------------------------"
Change-State -name "Demosite2" -website -stop




write-host "--------------------------------"
write-host "--------------------------------"
write-host "--------------------------------"
New-Virtualdir -name "testvdir" -site "Demosite" -path C:\temp -myhash @{}
write-host "--------------------------------"
Virtualdir-Exists -name "testvdir"
write-host "--------------------------------"
Check-VDirProperties -site "Demosite" -name "testvdir" -myhash @{}
write-host "--------------------------------"
Config-VDir -name "testvdir" -site "Demosite" -myhash @{} 



write-host "--------------------------------"
write-host "--------------------------------"
write-host "--------------------------------"
New-WebApp -name "a" -site "DemoSite" -myhash @{} -pool "DemoPool" -path "C:\temp"
write-host "--------------------------------"
Webapp-Exists  -name "a" -site "DemoSite"
write-host "--------------------------------"
Check-WebappProperties  -name "a" -site "DemoSite" -myhash @{} 
write-host "--------------------------------"
Config-Webapp  -name "a" -site "DemoSite" -myhash @{} 
write-host "--------------------------------"

write-host "--------------------------------"
write-host "--------------------------------"
write-host "--------------------------------"
write-host "Cleanup"
Delete-Virtualdir -name "testvdir" -site "Demosite" 
write-host "--------------------------------"
Delete-Webapp -site "demosite" -name "a"
write-host "--------------------------------"
Delete-Website -name "Demosite"
write-host "--------------------------------"
Delete-Website -name "Demosite2"
write-host "--------------------------------"
Delete-Website -name "Demosite3"
write-host "--------------------------------"
Delete-Pool -name "demopool"
write-host "--------------------------------"
write-host "--------------------------------"
write-host "--------------------------------"
write-host "--------------------------------"


Check-WebProperties -myhash @{"logfile.directory"="C:\logs\W3SVC"; "logfile.LogExtFileFlags"="Date,Time"} -filter "System.Applicationhost/Sites/SiteDefaults"
Config-Web -myhash @{"logfile.directory"="C:\logs\W3SVC"; "logfile.LogExtFileFlags"="Date,Time"} -filter "System.Applicationhost/Sites/SiteDefaults"
Config-Web -myhash @{"recycling.logEventOnRecycle"="Time,Requests,Memory,IsapiUnhealthy,OnDemand,ConfigChange"} -filter "System.Applicationhost/ApplicationPools/ApplicationPoolDefaults"
#Config-Web -myhash @{"logfile.directory"="C:\logs\W3SVC22"; "logfile.LogExtFileFlags"="Date,Time,ServerIP"} -filter "" <-- error case