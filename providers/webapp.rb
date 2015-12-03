use_inline_resources

def load_current_resource

	require 'mixlibrary/core/apps/shell'
	@current_resource = Chef::Resource::IisposhWebapp.new(@new_resource.name)
	@current_resource.name(@new_resource.name)
	@current_resource.path(@new_resource.path)
	@current_resource.pool(@new_resource.pool)
	@current_resource.site(@new_resource.site)
	@powershell_code = Chef::IISPOSH::Common_code.ps_code(@new_resource.properties)
	
end

# Create Action
action :create do
	@current_resource.exists = false
	if webapp_exists(@current_resource) 
		@current_resource.exists = true
	end	
	if @current_resource.exists
		Chef::Log.debug("Not running converge action")
	else	
		create_webapp(@new_resource)
		Chef::Log.debug("Running Converged Action ..................................")
		@new_resource.updated_by_last_action(true)
	end
end

# Cofnig Action
action :config do
	@current_resource.exists = false
	@current_resource.configured = false
	if webapp_exists(@current_resource) 
		@current_resource.exists = true
		if webapp_configured(@current_resource)
			@current_resource.configured = true
		end	
	end
	if !@current_resource.exists
		Chef::Log.debug("Not running converge action")
		raise "Unable to Configure Web App - Web App doesn't Exist!"
	elsif @current_resource.configured
		Chef::Log.debug("Not running converge action")
	else
		config_webapp(@new_resource)
		Chef::Log.debug("Running Converged Action ..................................")
		Chef::Log.debug("WebApp Properties - HASH ----------------------------------------")
		Chef::Log.debug(@new_resource.properties)
		@new_resource.updated_by_last_action(true)
	end	
end	

# Delete Action
action :delete do
	@current_resource.exists = false
	if webapp_exists(@current_resource) 
		@current_resource.exists = true
	end	
	if !@current_resource.exists
		Chef::Log.debug("Not running converge action")
	else	
		delete_webapp(@new_resource)
		Chef::Log.debug("Running Converged Action ..................................")
		@new_resource.updated_by_last_action(true)
	end
end

# Check if Webapp Exists
def webapp_exists(my_current_resource)
	
	name		= "#{my_current_resource.name}"
	site		= "#{my_current_resource.site}"
		
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$results = Webapp-Exists -name "#{name}" -site "#{site}"
		if($results)
		{
			
			exit 55
		}
		else
		{
			exit 66
		}
	EOF
	
	Chef::Log.debug "Webapp Name: #{name}"
			
	exit_status = Chef::IISPOSH::Common_code.exit_code(script)  
	if exit_status == 55
		Chef::Log.debug "WebApp alerady Exists: #{name}"
		return true
	elsif exit_status == 66
		Chef::Log.debug "WebApp Doesn't exist: : #{name}"
		return false
	else
		raise "Something happened Checking for WebApp: : #{name}"
	end	
	
end

# Check if WebApp is configured
def webapp_configured(my_current_resource)
	
	name		= "#{my_current_resource.name}"
	site		= "#{my_current_resource.site}"
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$results = Check-WebappProperties -site "#{site}" -name "#{name}"   -myhash #{@powershell_code} 
		if($results)
		{
			exit 55
		}
		else
		{
			exit 66
		}
	EOF
	
	Chef::Log.debug "Webapp Name: #{name}"
	
	exit_status = Chef::IISPOSH::Common_code.exit_code(script)
	if exit_status == 55
		Chef::Log.debug "WebApp alerady configured: #{name}"
		return true
	elsif exit_status == 66
		Chef::Log.debug "WebApp Not configured: : #{name}"
		return false
	else
		raise "Something happened Checking the Properties for WebApp: : #{name}"
	end	
	
end


# Create WebApp
def create_webapp(my_current_resource)

	name		= "#{my_current_resource.name}"
	site		= "#{my_current_resource.site}"
	path		= "#{my_current_resource.path}"
	pool		= "#{my_current_resource.pool}"
		
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$results = New-Webapp -name "#{name}" -site "#{site}" -pool "#{pool}" -path "#{path}" -myhash #{@powershell_code}   
		if($results)
		{
			exit 55
		}
		else
		{
			exit 66
		}
	EOF
	Chef::Log.debug "WebApp Name: #{name}"
	
		
	exit_status = Chef::IISPOSH::Common_code.exit_code(script)
	if exit_status == 55
		Chef::Log.debug "WebApp successfully created: #{name}"
	elsif exit_status == 66
		raise "Error Creating WebApp: : #{name}"
	else
		raise "Something happened while Creating the WebApp: : #{name}"
	end	
	

end	

# Configure WebApp
def config_webapp(my_current_resource)
	name		= "#{my_current_resource.name}"
	site		= "#{my_current_resource.site}"
	
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$results = Config-Webapp -name "#{name}" -site "#{site}" -myhash #{@powershell_code} 
		if($results)
		{
			exit 15
		}
		else
		{
			exit 16
		}
	EOF
	Chef::Log.debug "Webapp Name: #{name}"
	Chef::Log.debug("powershell_code----------------------")
	Chef::Log.debug(@powershell_code)
	
		
	exit_status = Chef::IISPOSH::Common_code.exit_code(script)
	if exit_status == 15
		Chef::Log.debug "WebApp Properties successfully set: #{name}"
	elsif exit_status == 16
		Chef::Log.debug "Error setting WebApp Properties: : #{name}"
	else
		raise "Something happened while Configuring the WebApp: : #{name}"
	end	
	

end

#Delete WebApp
def delete_webapp(my_current_resource)

	name		= "#{my_current_resource.name}"
	site		= "#{my_current_resource.site}"
			
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$results = Delete-Webapp -site "#{site}" -name "#{name}" 
		if($results)
		{
			exit 55
		}
		else
		{
			exit 66
		}
	EOF
	Chef::Log.debug "WebApp Name: #{name}"
	
		
	exit_status = Chef::IISPOSH::Common_code.exit_code(script)
	if exit_status == 55
		Chef::Log.debug "WebApp successfully Deleted: #{name}"
	elsif exit_status == 66
		raise "Error Deleting WebApp: : #{name}"
	else
		raise "Something happened while Deleting the WebApp: : #{name}"
	end	
	

end	

	
	