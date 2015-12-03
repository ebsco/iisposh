#
# Cookbook Name:: iisposh
# Recipe:: iis_pool
#
# Copyright 2015, Ebsco
#
# All rights reserved - Do Not Redistribute

include_recipe 'iisposh::default'


# Application Pool Action - create, config, delete, start, stop
iisposh_pool 'pool' do 
	name "DemoPool"
	properties(
			"recycling.periodicRestart.privatememory" => 4,
			"processmodel.maxprocesses" => 3,
			"managedPipeLineMode" => "Integrated",
			"managedRunTimeVersion" => "v2.0",
			"processModel.IdentityType" => "NetworkService",
			"autostart" => "True",
			"processmodel.pingingenabled" => "true",
			"enable32BitAppOnWin64" => "false",
			"processmodel.username" => "",
			"processmodel.password"	=> "",
			"recycling.logEventOnRecycle" => "Time,Requests,IsapiUnhealthy,OnDemand,ConfigChange"	
	)
	action [:create,:config,:start]
end


#Demo Site
iisposh_website 'website' do 
	name "Demosite"
	bindings [["http", "3030", "ebsco.com", "10.10.10.10"],["https", "4343", "", "12.12.12.12"],["http", "9092", "", ""]]
	properties(
			"applicationPool" => "DemoPool",
			"physicalPath"	=> "c:\\temp",
			"ServerAutoStart" => "True",
			"logfile.logformat" => "W3C",
			"logfile.directory" => "c:\\weblogs",
			"limits.connectionTimeout" => "00:03:00",
			"logfile.logExtFileFlags" => "Date,Time,ClientIP,ServerIP,Method,UriStem,UriQuery,HttpStatus,BytesSent,TimeTaken,UserAgent"
	)
	action :create
end

iisposh_website 'website2' do 
	name "Demosite2"
	bindings [["http", "9093", "", ""]]
	properties(
			"applicationPool" => "DemoPool",
			"physicalPath"	=> "c:\\temp",
			"ServerAutoStart" => "True",
			"logfile.logformat" => "W3C",
			"logfile.directory" => "c:\\weblogs",
			"limits.connectionTimeout" => "00:03:00",
			"logfile.logExtFileFlags" => "Date,Time,ClientIP,ServerIP,Method,UriStem,UriQuery,HttpStatus,BytesSent,TimeTaken,UserAgent"
	)
	action :create
end


# Webconfiguration - config
iisposh_webconfiguration 'webconfig' do 
	name "Demosite"
  filter "System.Applicationhost/Sites/SiteDefaults"
	properties(
			"logfile.directory" => "C:\\logs\\W3SVC",
			"logfile.LogExtFileFlags" => "Date,Time"
	)
	action [:config]
end


iisposh_vdir 'vdir' do 
	name "Demodir"
	site "Demosite"
	path "c:/temp"
	properties(
		"logonMethod" => "ClearText",
		"allowSubDirConfig" => "True"
		
	)
	action [:create,:config]
end

# Webapp Action - create, config, or delete
iisposh_webapp 'webapp' do 
	name "DemoApp"
	site "Demosite"
	path "c:/temp"
	pool  "DemoPool"
	
	action [:create,:config]
end
