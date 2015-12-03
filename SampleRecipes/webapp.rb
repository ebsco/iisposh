include_recipe 'iisposh::default'


# Webapp Action - create, config, or delete
iisposh_webapp 'webapp' do 
	name "DemoApp"
	site "Demosite"
	path "c:/temp"
	properties(
		"username" => "",   # example:  corp\\username
		"password" => ""
	)
	
	action :create 
end