use_inline_resources

def load_current_resource

	require 'mixlibrary/core/apps/shell'
	
	@current_resource = Chef::Resource::IisposhVdir.new(@new_resource.name)
	@current_resource.name(@new_resource.name)
	@current_resource.path(@new_resource.path)
	@current_resource.site(@new_resource.site)
	@powershell_code = Chef::IISPOSH::Common_code.ps_code(@new_resource.properties)
	
end

# Create Action
action :create do

	@current_resource.exists = false
	if virtualdir_exists(@current_resource) 
		@current_resource.exists = true
	end
	if @current_resource.exists
		Chef::Log.debug("Not running converge action")
	else	
		create_virtualdir(@new_resource)
		Chef::Log.debug("Running Converged Action ..................................")
		@new_resource.updated_by_last_action(true)
				
	end
	
	
end

# Cofnig Action
action :config do
	@current_resource.exists = false
	@current_resource.configured = false
	if virtualdir_exists(@current_resource) 
		@current_resource.exists = true
		if virtualdir_configured(@current_resource)
			@current_resource.configured = true
		end	
	end
	if !@current_resource.exists
		Chef::Log.debug("Not running converge action")
		raise "Unable to Configure Virtual Directory - Virtual Directory dosen't Exist!"
	elsif @current_resource.configured
		Chef::Log.debug("Not running converge action")
	else
		config_virtualdir(@new_resource)
		Chef::Log.debug("Running Converged Action ..................................")
		Chef::Log.debug("Virtual Directory Properties - HASH ----------------------------------------")
		Chef::Log.debug(@new_resource.properties)
		@new_resource.updated_by_last_action(true)
	end	
end	

# Delete Action
action :delete do

	@current_resource.exists = false
	if virtualdir_exists(@current_resource) 
		@current_resource.exists = true
	end
	if !@current_resource.exists
		Chef::Log.debug("Not running converge action")
	else	
		delete_virtualdir(@new_resource)
		Chef::Log.debug("Running Converged Action ..................................")
		@new_resource.updated_by_last_action(true)
						
	end
	
	
end

# Check if Website Exists
def virtualdir_exists(my_current_resource)
	
	name		= "#{my_current_resource.name}"
	site		= "#{my_current_resource.site}"		
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$results = Virtualdir-Exists -name "#{name}"
		if($results)
		{
			exit 55
		}
		else
		{
			exit 66
		}
	EOF
	
	Chef::Log.debug "virtual directory Name: #{name}"
			
	exit_status = Chef::IISPOSH::Common_code.exit_code(script)
	if exit_status == 55
		Chef::Log.debug "Virtual Directory alerady Exists: #{name}"
		return true
	elsif exit_status == 66
		Chef::Log.debug "Virutal Directory Doesn't exist: #{name}"
		return false
	else
		raise "Something happened Checking for Virutal Directory: #{name}"
	end	
	
end

# Check if Virtual Directory is configured
def virtualdir_configured(my_current_resource)
	
	name		= "#{my_current_resource.name}"
	site		= "#{my_current_resource.site}"
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$results = Check-VDirProperties -site "#{site}" -name "#{name}" -myhash #{@powershell_code} 
		if($results)
		{
			
			exit 55
		}
		else
		{
			exit 66
		}
	EOF
	
	Chef::Log.debug "Virtual Directory Name: #{name}"
			
	exit_status = Chef::IISPOSH::Common_code.exit_code(script)
	if exit_status == 55
		Chef::Log.debug "Virtual Directory alerady configured: #{name}"
		return true
	elsif exit_status == 66
		Chef::Log.debug "Virtual Directory Not configured: #{name}"
		return false
	else
		raise "Something happened Checking the Properties for Virtual Directory: #{name}"
	end	
	
end


# Create Virtual Directory
def create_virtualdir(my_current_resource)

	name		= "#{my_current_resource.name}"
	site		= "#{my_current_resource.site}"
	path		= "#{my_current_resource.path}"
			
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$results = New-Virtualdir -name "#{name}" -site "#{site}" -path "#{path}" -myhash #{@powershell_code} 
		if($results)
		{
			exit 55
		}
		else
		{
			exit 66
		}
	EOF
	Chef::Log.debug "Virtual Directory Name: #{name}"
			
	exit_status = Chef::IISPOSH::Common_code.exit_code(script)
	if exit_status == 55
		Chef::Log.debug "Virtual Directory successfully created: #{name}"
	elsif exit_status == 66
		raise "Error Creating Virtual Directory: #{name}"
	else
		raise "Something happened while Creating the Virtual Directory: #{name}"
	end	
	

end	

# Delete Virtual Directory
def delete_virtualdir(my_current_resource)

	name		= "#{my_current_resource.name}"
	site		= "#{my_current_resource.site}"
			
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$results = Delete-Virtualdir -name "#{name}" -site "#{site}" 
		if($results)
		{
			exit 55
		}
		else
		{
			exit 66
		}
	EOF
	Chef::Log.debug "Virtual Directory Name: #{name}"
			
	exit_status = Chef::IISPOSH::Common_code.exit_code(script)
	if exit_status == 55
		Chef::Log.debug "Virtual Directory successfully Deleted: #{name}"
	elsif exit_status == 66
		raise "Error Deleting Virtual Directory: #{name}"
	else
		raise "Something happened while Deleting the Virtual Directory: #{name}"
	end	
	

end	

# Configure Virtual Directory
def config_virtualdir(my_current_resource)
	name		= "#{my_current_resource.name}"
	site		= "#{my_current_resource.site}"
	
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$results = Config-VDir -name "#{name}" -site "#{site}" -myhash #{@powershell_code} 
		if($results)
		{
			exit 15
		}
		else
		{
			exit 16
		}
	EOF
	Chef::Log.debug "Virtual Directory Name: #{name}"
	Chef::Log.debug("powershell_code----------------------")
	Chef::Log.debug(@powershell_code)
			
	exit_status = Chef::IISPOSH::Common_code.exit_code(script)
	if exit_status == 15
		Chef::Log.debug "Virtual Directory Properties successfully set: #{name}"
	elsif exit_status == 16
		Chef::Log.debug "Error setting Virtual Directory Properties: #{name}"
	else
		raise "Something happened while Configuring Virtual Directory: #{name}"
	end	
	

end


	
	