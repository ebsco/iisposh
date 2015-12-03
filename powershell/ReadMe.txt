Help discover the settings on your node to see wihch settings can be set using the  properties of the different LWRPs

We print out the global and child elements that can be set.

#Example calls
#Website
.\DiscoverSettings.ps1 -website -websitestr "Default Web Site"

#Web app Pool
.\DiscoverSettings.ps1 -apppool -apppoolstr "DefaultAppPool"

#Web App
.\DiscoverSettings.ps1 -webapp -webappstr "dsa" -websitestr "Default Web Site"

#virtual dir
.\DiscoverSettings.ps1 -virtualdir -virtualdirstr "test" -websitestr "DefaultWeb Site"

#bindings
.\DiscoverSettings.ps1 -bindings


#Website Example
Example stub output below:
---------------------------------------
Site Settings
"applicationDefaults.applicationPool" =>  "",
"applicationDefaults.enabledProtocols" =>  "http",
"applicationDefaults.path" =>  "",
"applicationDefaults.serviceAutoStartEnabled" =>  "False",
"applicationDefaults.serviceAutoStartProvider" =>  "",
"applicationPool" =>  "DefaultAppPool",
"bindings.Collection" =>  "Microsoft.IIs.PowerShell.Framework.ConfigurationElement",
WARNING: Trying to evaluate property Collection.applicationPool failed.
"Collection.Collection" =>  "Microsoft.IIs.PowerShell.Framework.ConfigurationElement Microsoft.IIs.PowerShell.Framework.ConfigurationElement",
WARNING: Trying to evaluate property Collection.enabledProtocols failed.
WARNING: Trying to evaluate property Collection.path failed.
WARNING: Trying to evaluate property Collection.serviceAutoStartEnabled failed.
WARNING: Trying to evaluate property Collection.serviceAutoStartProvider failed.
"Collection.virtualDirectoryDefaults" =>  "Microsoft.IIs.PowerShell.Framework.ConfigurationElement",
"enabledProtocols" =>  "http",
"ftpServer.allowUTF8" =>  "True",
"ftpServer.connections" =>  "Microsoft.IIs.PowerShell.Framework.ConfigurationElement",
"ftpServer.customFeatures" =>  "Microsoft.IIs.PowerShell.Framework.ConfigurationElement",
"ftpServer.directoryBrowse" =>  "Microsoft.IIs.PowerShell.Framework.ConfigurationElement",
"ftpServer.fileHandling" =>  "Microsoft.IIs.PowerShell.Framework.ConfigurationElement",
"ftpServer.firewallSupport" =>  "Microsoft.IIs.PowerShell.Framework.ConfigurationElement",
"ftpServer.logFile" =>  "Microsoft.IIs.PowerShell.Framework.ConfigurationElement",
"ftpServer.messages" =>  "Microsoft.IIs.PowerShell.Framework.ConfigurationElement",
"ftpServer.security" =>  "Microsoft.IIs.PowerShell.Framework.ConfigurationElement",
"ftpServer.serverAutoStart" =>  "True",
"ftpServer.userIsolation" =>  "Microsoft.IIs.PowerShell.Framework.ConfigurationElement",
"id" =>  "1",
"ItemXPath" =>  "@{ItemXPath=/system.applicationHost/sites/site[@name='Default Web Site' and @id='1']}",
"limits.connectionTimeout" =>  "00:02:00",
"limits.maxBandwidth" =>  "4294967295",
"limits.maxConnections" =>  "4294967295",
"logFile.customLogPluginClsid" =>  "",
"logFile.directory" =>  "%SystemDrive%\inetpub\logs\LogFiles",
"logFile.enabled" =>  "True",
"logFile.localTimeRollover" =>  "False",
"logFile.logExtFileFlags" =>  "Date,Time,ClientIP,UserName,ServerIP,Method,UriStem,UriQuery,HttpStatus,Win32Status,TimeTaken,ServerPort,UserAgent,Http,SubStatus",
"logFile.logFormat" =>  "W3C",
"logFile.period" =>  "Daily",
"logFile.truncateSize" =>  "20971520",
"name" =>  "Default Web Site",
"password" =>  "",
---------------END----------------------

END STUB
________________________________________________________________________________________
So to call the LWRP for website.  We might want to change logFile.logFormat and the limits.maxBandwidth.  Notice how maxBandwidth inside a child element of limits.

The LWRP call:

iisposh_website 'website' do 
	name "Demosite"
	bindings [["http", "80", "", ""],["https", "4343", "", ""],["http", "9092", "", ""]]
	properties(
			"applicationPool" => "DemoPool",
			"physicalPath"	=> "c:\\temp",
			"limits.maxBandwidth" =>  "4294967295",
;			"logFile.logFormat" =>  "W3C",
	)
	
	action [:create, :config]
end

We know what to put in the properties because basically the syntax is as follows:
Get-ItemProperty IIS:\Sites\$name -Name "PROPERTY_KEY"

When you call the above Cmdlet, replace your property key in with the -name parameter.  So in this example if I call: Get-ItemProperty "IIS:\Sites\DemoSite" -Name "applicationPool"
I get back in output:
DefaultAppPool

Now we have an extensible way of setting each setting on a website, pool, virtualdir etc.

The DiscoverSettings script was created to aid in discovering what settings exist.  As you can see in the above output it does not show the "applicationpool" setting.  It was outside of the scope to make this script perfect, but just to make it easier to discover the majority of the settings.

