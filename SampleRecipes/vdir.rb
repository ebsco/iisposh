include_recipe 'iisposh::default'


# Virtual Directory Action create, config, delete
iisposh_vdir 'vdir' do 
	name "Demodir"
	site "Demosite"
	path "c:/temp"
	properties(
		"logonMethod" => "ClearText",
		"allowSubDirConfig" => "True"
		
	)
	
	action :create
end