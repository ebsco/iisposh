include_recipe 'iisposh::default'


# Website Action create, config, delete, start, stop, restart
# Bindings format [["Protocol", "Port", "HostHeader", "IPAddress"], ["Protocol", "Port", "HostHeader", "IPAddress"], ....]
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