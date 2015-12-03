Description
===========

Manage websites, application pools, web applications, and virtual directories in IIS 7.0,7.5,8.0

Requirements
============

Platforms
---------

* Windows Server 2008 (R1, R2)
* Windows Server 2012 (R1, R2) (Untested)


Resource/Provider
=================

iisposh_pool
----------

Manage application pools in IIS

### Actions

- :create: - creates an application pool
- :config: - configure an application pool 
- :delete: - delete an existing application pool
- :start: - start an application pool
- :stop: - stop an application pool
- :restart: - restart an application pool

### Attribute Parameters

- name: name of application pool
- properties: List of all properties to be set for application pool

### Examples

	# Create an application pool named TestPool with the following properties set
	# recycling.periodicRestart.privatememory" = 4, processmodel.maxprocesses = 3, managedPipeLineMode = Integrated, managedRunTimeVersion = v4.0
	# processModel.IdentityType = SpecificUser, Autostart = True, processmodel.username = mydomain\username, processmodel.password = mypassword, recycling.logEventOnRecycle = Time,Requests,IsapiUnhealthy,OnDemand,ConfigChange

	iisposh_pool 'pool' do 
		name "TestPool"
		properties(
				"recycling.periodicRestart.privatememory" => 4,
				"processmodel.maxprocesses" => 3,
				"managedPipeLineMode" => "Integrated",
				"managedRunTimeVersion" => "v2.0",
				"processModel.IdentityType" => "SpecificUser",
				"autostart" => "True",
				"processmodel.username" => "mydomain\\username",
				"processmodel.password"	=> "mypassword",
				"recycling.logEventOnRecycle" => "Time,Requests,IsapiUnhealthy,OnDemand,ConfigChange"	
		)
		action :create
	end

	# Delete the TestPool Application Pool
	
	iisposh_pool 'pool' do 
		name "TestPool"
		action :delete
	end



iisposh_website
---------

Allows easy management of IIS Websites

### Actions

- :create: - creates a new website
- :config: - configure a website
- :delete: - delete an existing website
- :start: - start a website
- :stop: - stop a website
- :restart: - restart a website

### Attribute Parameters

- name: name of website
- path: Physical path of website files
- pool: Application pool of the website
- properties: List of all properties to be set for website
- bindings: Set website web bindings [["protocol", "port#","hostheader", "IPAddress"]]
- powershell_code: String used to convert ruby hashtable to powershell hashtable
- binding_string: String used to convert ruby array into format usable by powersehll

### Examples
  # create a new website at the location C:\inetpub\wwwroot\testsite with default binding of port 80
	
	iisposh_website 'website' do 
		name "TestSite"
		action :create
	end
  
	# create a new website at the location C:\inetpub\wwwroot\testsite with the following properties set
	# name = TestSite, applicationPool = TestPool, ServerAutoStart = True, logFile.logFormat = W3C, logfile.deirectory = c:\weblogs, logfile.logExtFileFalgs = Date,Time,ClientIP,ServerIP,Method,UriStem,UriQuery,HttpStatus,BytesSent,TimeTaken,UserAgent
	# bindings = http,3030
	
	iisposh_website 'website' do 
		name "TestSite"
		bindings [["http", "3030", "", ""]]
		properties(
				"applicationPool" => "TestPool",
				"physicalPath"	=> "c:\\inetpub\\wwwroot\\testsite",
				"ServerAutoStart" => "True",
				"logfile.logformat" => "W3C",
				"logfile.directory" => "c:\\weblogs",
				"logfile.logExtFileFlags" => "Date,Time,ClientIP,ServerIP,Method,UriStem,UriQuery,HttpStatus,BytesSent,TimeTaken,UserAgent"
		)
		action :create
	end
	
	# Delete the TestSite website
	
		iisposh_website 'website' do 
			name "TestSite"
			action :delete
		end
		
	# configure a website with the following properties
	# name = TestSite, applicationPool = TestPool, ServerAutoStart = True, logFile.logFormat = W3C, logfile.deirectory = c:\weblogs, logfile.logExtFileFalgs = Date,Time,ClientIP,ServerIP,Method,UriStem,UriQuery,HttpStatus,BytesSent,TimeTaken,UserAgent
	# bindings = http,3030	
		
	iisposh_website 'website' do 
		name "TestSite"
		bindings [["http", "3030", "", ""]]
		properties(
				"applicationPool" => "TestPool",
				"physicalPath"	=> "c:\\inetpub\\wwwroot\\testsite",
				"ServerAutoStart" => "True",
				"logfile.logformat" => "W3C",
				"logfile.directory" => "c:\\weblogs",
				"logfile.logExtFileFlags" => "Date,Time,ClientIP,ServerIP,Method,UriStem,UriQuery,HttpStatus,BytesSent,TimeTaken,UserAgent"
		)
		action :config
	end	

	# configure a website with the following properties
	# name = TestSite, applicationPool = TestPool, ServerAutoStart = True, logFile.logFormat = W3C, logfile.deirectory = c:\weblogs, logfile.logExtFileFalgs = Date,Time,ClientIP,ServerIP,Method,UriStem,UriQuery,HttpStatus,BytesSent,TimeTaken,UserAgent
		
	iisposh_website 'website' do 
		name "TestSite"
		properties(
				"applicationPool" => "TestPool",
				"physicalPath"	=> "c:\\inetpub\\wwwroot\\testsite",
				"ServerAutoStart" => "True",
				"logfile.logformat" => "W3C",
				"logfile.directory" => "c:\\weblogs",
				"logfile.logExtFileFlags" => "Date,Time,ClientIP,ServerIP,Method,UriStem,UriQuery,HttpStatus,BytesSent,TimeTaken,UserAgent"
		)
		action :config
	end	
  
	# restart the TestSite website
	
	iisposh_website 'website' do 
		name "TestSite"
		action :resetart
	end
	
	
iisposh_webapp
------------
Manage web applications in IIS

### Actions

- :create: - create a web application
- :config: - configure a web application
- :delete: - delete a web application

### Attribute Parameters

- name: Name of web application
- path: Physical Path of web application files
- site: Name of the website in which the web application belongs to
- pool: Name of the Application Pool the web application runs under
- properties: List of properties to be set for the application pool

### Examples

	# Create a web application named "TestApp" located at "c:\temp" under the "TestSite" running under the "TestPool" application pool
	
	iisposh_webapp 'webapp' do 
		name "TestApp"
		pool "TestPool"
		site "TestSite"
		path "c:\\temp"
		properties(
			"username" => "",   # example:  domain\\username
			"password" => ""
		)
		action :create 
	end
	
	# Delete the "TestApp" web application under the "TestSite" website
	
	iisposh_webapp 'webapp' do 
		name "TestApp"
		site "TestSite"
		action :delete 
	end
	

iisposh_vdir
----------
Manage Virtual Directories in  IIS

### Actions

- :create: - create a virtual directory
- :config: - configure a virtual directory
- :delete: - delete a virtual directory

### Attribute Parameters

- name: Name of virtual directory
- path: Physical Path of virtual directory files
- site: Name of the website in which the virtual directory belongs to
- properties: List of properties to be set for the virutal directory

### Examples

	# Create a virtual directory named "TestDir" under the "TestSite" website with a path of c:\Temp with the following properties set
	# logonMetohod = ClearText, AllowSubDir Config = True
	
	iisposh_vdir 'vdir' do 
		name "Testdir"
		site "TestSite"
		path "c:\\temp"
		properties(
			"logonMethod" => "ClearText",
			"allowSubDirConfig" => "True"
			
		)
		
		action :create
	end
 
	# Delete the "TestDir" Virtual Director in the "TestSite" website
	
	iisposh_vdir 'vdir' do 
		name "Testdir"
		site "TestSite"
		action :delete
	end
	
Helpers
----------
 * See powershell folder
   * Wrote a powershell script to help discover settings of currently deployed components in IIS.  Pools, WebApps, Sites etc
 * files\default\test.ps1
   * To aid in testing of powershell outside of chef and LWRPs, test.ps1 was created to help test the different function calls.

Author
------

* Author:: Darrell Johnson (<darrellj@ebsco.com>)	
* Author:: Nicholas Carpenter (<ncarpenter@ebsco.com>)	