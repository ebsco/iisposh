use_inline_resources

def load_current_resource

	require 'mixlibrary/core/apps/shell'
	
	@current_resource = Chef::Resource::IisposhWebconfiguration.new(@new_resource.name)
	@current_resource.name(@new_resource.name)
	@current_resource.properties(@new_resource.properties)
  @current_resource.filter(@new_resource.filter)
	@powershell_code = Chef::IISPOSH::Common_code.ps_code(@new_resource.properties)
	
	@current_resource.configured = false
	if web_configured(@current_resource) 
		@current_resource.configured = true
	end	
end

# Config Action
action :config do
	if @current_resource.configured 
		Chef::Log.debug("Not running Converged Action")
	else
		config_web(@new_resource)
		Chef::Log.debug("Running Converged Action ..................................")
		Chef::Log.debug("Web Properties - HASH ----------------------------------------")
		Chef::Log.debug(@new_resource.properties)
		@new_resource.updated_by_last_action(true)
	end
end

# Web Configured
def web_configured(my_current_resource)
	
	name		= "#{my_current_resource.name}"
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$results = Check-WebProperties -myhash #{@powershell_code} -filter "#{@current_resource.filter}"
		if($results)
		{
			
			exit 55
		}
		else
		{
			exit 66
		}
	EOF
	Chef::Log.debug "Pool Name: #{name}"
	exit_status = Chef::IISPOSH::Common_code.exit_code(script)	
	
	if exit_status == 55
		Chef::Log.debug "All Properties Configured: #{name}"
		return true
	elsif exit_status == 66
		Chef::Log.debug "Properties need Configured"
		return false
	else
		raise "Something happened Checking Configuration"
	end	
	
end

# Config Web Defualts
def config_web(my_current_resource)

	name		= "#{my_current_resource.name}"
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$configweb = Config-Web -myhash #{@powershell_code}  -filter "#{@new_resource.filter}"
			exit 55
		
	EOF
	Chef::Log.debug("powershell_code----------------------")
	Chef::Log.debug(@powershell_code)
	
		
	exit_status = Chef::IISPOSH::Common_code.exit_code(script)
	
	if exit_status == 55
		Chef::Log.debug "Web Defaults successfully set: #{name}"
	elsif exit_status == 66
		raise "Error setting Web Defaults"
	else
		raise "Something happened while Configuring the Web Defaults"
	end	
end	




	
	