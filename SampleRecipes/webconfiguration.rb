include_recipe 'iisposh::default'


# Webconfiguration - config
iisposh_webconfiguration 'webconfig' do 
	name "Demosite"
  filter "System.Applicationhost/Sites/SiteDefaults"
	properties(
			"logfile.directory" => "C:\\logs\\W3SVC",
			"logfile.LogExtFileFlags" => "Date,Time"
	)
	
	action :config
end


