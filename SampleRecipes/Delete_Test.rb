#
# Cookbook Name:: iisposh
# Recipe:: iis_pool
#
# Copyright 2015, Ebsco
#
# All rights reserved - Do Not Redistribute

include_recipe 'iisposh::default'


iisposh_vdir 'vdir' do 
	name "Demodir"
	site "Demosite"
	path "c:/temp"
	action [:delete]
end

# Webapp Action - create, config, or delete
iisposh_webapp 'webapp' do 
	name "DemoApp"
	site "Demosite"
	path "c:/temp"
	pool  "DemoPool"
	
	action [:delete]
end


#Demo Site
iisposh_website 'website' do 
	name "Demosite"
	action :delete
end

iisposh_website 'website2' do 
	name "Demosite2"
	action :delete
end

# Application Pool Action - create, config, delete, start, stop
iisposh_pool 'pool' do 
	name "DemoPool"
	action [:delete]
end
