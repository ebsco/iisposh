#Getting mixlibrary-core from windows_feature cookbook
include_recipe 'windows_feature::default'

# create directory on server
directory "#{cookbook_name}_pool_directory" do
	path "#{node['iisposh']['scripts_basedir']}"
	action :create
end

# Copy Powershell files to the server

cookbook_file "#{cookbook_name}_ps_common" do
	source "common.ps1"
	path ::File.join(node['iisposh']['scripts_basedir'], "common.ps1") 
	action :create
end
cookbook_file "#{cookbook_name}_ps_iis_web_tools" do
	source "iis_web_tools.ps1"
	path ::File.join(node['iisposh']['scripts_basedir'], "iis_web_tools.ps1") 
	action :create
end
cookbook_file "#{cookbook_name}_ps_pools" do
	source "pools.ps1"
	path ::File.join(node['iisposh']['scripts_basedir'], "pools.ps1") 
	action :create
end
cookbook_file "#{cookbook_name}_ps_test" do
	source "test.ps1"
	path ::File.join(node['iisposh']['scripts_basedir'], "test.ps1") 
	action :create
end
cookbook_file "#{cookbook_name}_ps_virtualdirs" do
	source "virtualdirs.ps1"
	path ::File.join(node['iisposh']['scripts_basedir'], "virtualdirs.ps1") 
	action :create
end
cookbook_file "#{cookbook_name}_ps_webapps" do
	source "webapps.ps1"
	path ::File.join(node['iisposh']['scripts_basedir'], "webapps.ps1") 
	action :create
end

cookbook_file "#{cookbook_name}_ps_websites" do
	source "websites.ps1"
	path ::File.join(node['iisposh']['scripts_basedir'], "websites.ps1") 
	action :create
end

cookbook_file "#{cookbook_name}_ps_webprops" do
	source "webprops.ps1"
	path ::File.join(node['iisposh']['scripts_basedir'], "webprops.ps1") 
	action :create
end


# copy iis_changelist.xml fo the server - needed for the powershell oddity in 2008. Some item properties return Strings but have to be set by Integers.  So XML file stores these properties and the matching integer values

cookbook_file "#{cookbook_name}_xml_cookbook_file" do
    source "iis_changelist.xml"
    path    ::File.join(node['iisposh']['scripts_basedir'], "iis_changelist.xml")
 end
 