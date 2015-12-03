use_inline_resources

def load_current_resource

	require 'mixlibrary/core/apps/shell'
	
	@current_resource = Chef::Resource::IisposhWebsite.new(@new_resource.name)
	@current_resource.name(@new_resource.name)
	@current_resource.path(@new_resource.path)
	@current_resource.pool(@new_resource.pool)
	@current_resource.properties(@new_resource.properties)
	@current_resource.bindings(@new_resource.bindings)
	@powershell_code 	= Chef::IISPOSH::Common_code.ps_code(@new_resource.properties)
	@bindings_string	= Chef::IISPOSH::Common_code.binding_code(@new_resource.bindings)
end

# Create Action
action :create do
	@current_resource.exists = false
	if web_exists(@current_resource) 
		@current_resource.exists = true
	end	
	if @current_resource.exists
		Chef::Log.debug("Not running converge action")
	else	
		create_website(@new_resource)
		Chef::Log.debug("Running Converged Action ..................................")
		Chef::Log.debug("Properties - HASH ----------------------------------------")
		Chef::Log.debug(@new_resource.properties)
		Chef::Log.debug("Bindings **********************************************************")
		Chef::Log.debug(@new_resource.bindings)
		@new_resource.updated_by_last_action(true)
	end
end

# Config Action
action :config do

	@current_resource.exists = false
	@current_resource.configured = false
	
	if web_exists(@current_resource) 
		@current_resource.exists = true
		if web_configured(@current_resource)
			@current_resource.configured = true
		end
	end	
	if !@current_resource.exists
		Chef::Log.debug("Not running converge action")
		raise "Unable to Configure Website - Website doesn't Exist!"
	elsif @current_resource.configured
		Chef::Log.debug("Not running converge action")
	else	
		config_website(@new_resource)
		Chef::Log.debug("Running Converged Action ..................................")
		Chef::Log.debug("Properties - HASH ----------------------------------------")
		Chef::Log.debug(@new_resource.properties)
		@new_resource.updated_by_last_action(true)				
	end
end

# Delete Action
action :delete do

	@current_resource.exists = false
	if web_exists(@current_resource) 
		@current_resource.exists = true
	end	
	if !@current_resource.exists
		Chef::Log.debug("Not running converge action")
	else	
		delete_website(@new_resource)
		Chef::Log.debug("Running Converged Action ..................................")
		@new_resource.updated_by_last_action(true)				
	end
end


# Stop Action
action :stop do

	@current_resource.exists = false
	@current_resource.running = false
	if web_exists(@current_resource) 
		@current_resource.exists = true
		if web_running(@current_resource)
			@current_resource.running = true
		end	
	end	
	if !@current_resource.exists
		Chef::Log.debug("Not running converge action")
		raise "Unable to stop Website - Website doesn't exist!"
	elsif !@current_resource.running
		Chef::Log.debug("Not running converge action")
	else	
		stop_website(@new_resource)
		Chef::Log.debug("Running Converged Action ..................................")
		@new_resource.updated_by_last_action(true)				
	end
end

# Start Action
action :start do

	@current_resource.exists = false
	@current_resource.running = false
	if web_exists(@current_resource) 
		@current_resource.exists = true
		if web_running(@current_resource)
			@current_resource.running = true
		end	
	end	
	if !@current_resource.exists 
		Chef::Log.debug("Not running converge action")
		raise "Website can't be started - Website doesn't exist!"
	elsif @current_resource.running
		Chef::Log.debug("Not running converge action")
	else	
		start_website(@new_resource)
		Chef::Log.debug("Running Converged Action ..................................")
		@new_resource.updated_by_last_action(true)				
	end
end

# Restart Action
action :restart do

	@current_resource.exists = false
	@current_resource.running = false
	if web_exists(@current_resource) 
		@current_resource.exists = true
	end	
	if !@current_resource.exists
		Chef::Log.debug("Not running converge action")
		raise "Unable to Restart Website - Website doesn't Exist!"
	else	
		restart_website(@new_resource)
		Chef::Log.debug("Running Converged Action ..................................")
		@new_resource.updated_by_last_action(true)				
	end
end

# Check if Website Exists
def web_exists(my_current_resource)
	
	name		= "#{my_current_resource.name}"
				
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$results = Website-Exists -name "#{name}" 
		if($results)
		{
			exit 55
		}
		else
		{
			exit 66
		}
	EOF
	
	Chef::Log.debug "Website Name: #{name}"
	exit_status = Chef::IISPOSH::Common_code.exit_code(script)
	if exit_status == 55
		Chef::Log.debug "Website alerady Exists: #{name}"
		return true
	elsif exit_status == 66
		Chef::Log.debug "Website Doesn't exist: #{name}"
		return false
	else
		raise "Something happened Checking for Website: #{name}"
	end	
end

# Check if WebApp is configured
def web_configured(my_current_resource)
	
	name		= "#{my_current_resource.name}"
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		
			$results = Check-WebSiteProperties -name "#{name}" -myhash #{@powershell_code}  -bindings #{@bindings_string}
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
	Chef::Log.debug "#{ exit_status }"

	if exit_status == 55
		Chef::Log.debug "Website alerady configured: #{name}"
		return true
	elsif exit_status == 66
		Chef::Log.debug "Website Not configured: #{name}"
		return false
	else
		raise "Something happened Checking the Properties for Website: #{name}"
	end	
end

# Check if Website is running
def web_running(my_current_resource)
	
	name		= "#{my_current_resource.name}"
				
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$results = Get-Runningstate -name "#{name}" -website
		if($results)
		{
			exit 55
		}
		else
		{
			exit 66
		}
	EOF
	
	Chef::Log.debug "Website Name: #{name}"
	exit_status = Chef::IISPOSH::Common_code.exit_code(script)
	if exit_status == 55
		Chef::Log.debug "Website is Running: #{name}"
		return true
	elsif exit_status == 66
		Chef::Log.debug "Website is Stopped: #{name}"
		return false
	else
		raise "Something happened Checking for Website State: #{name}"
	end	
end

# Create Website
def create_website(my_current_resource)

	name				= "#{my_current_resource.name}"
			
	script = <<-EOF
		. #{node['iisposh']['ps_path']}

			$results = New-Iisweb -name "#{name}" -myhash #{@powershell_code} -bindings #{@bindings_string}
			write-host #{@bindings_string}
			if($results)
			{
				exit 55
			}
			else
			{
				exit 66
			}		
	EOF
	Chef::Log.debug "Website Name: #{name}"
	
	
	exit_status = Chef::IISPOSH::Common_code.exit_code(script)
	if exit_status == 55
		Chef::Log.debug "Website successfully created: #{name}"
	elsif exit_status == 66
		raise "Error Creating Website: #{name}"
	else
		raise "Something happened while Creating the Website: #{name}"
	end	
end	

# Config Website
def config_website(my_current_resource)

	name				= "#{my_current_resource.name}"
			
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$results = Configure-Website -bindings #{@bindings_string} -name "#{name}" -myhash #{@powershell_code}
		if ($results)
		{	
				exit 55
		}
		else
		{
			exit 66
		}
		
	EOF
	Chef::Log.debug "Website Name: #{name}"
	Chef::Log.debug("Powershell Code----------------------")
	Chef::Log.debug(@powershell_code)
	
	exit_status = Chef::IISPOSH::Common_code.exit_code(script)
	if exit_status == 55
		Chef::Log.debug "Website successfully configured: #{name}"
	elsif exit_status == 66
		raise "Error configuring Website: #{name}"
	else
		raise "Something happened while configuring the Website: #{name}"
	end	
end	

# Delete Website
def delete_website(my_current_resource)

	name		= "#{my_current_resource.name}"
			
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$results = Delete-Website -name "#{name}" 
		if($results)
		{
			exit 55
		}
		else
		{
			exit 66
		}
	EOF
	Chef::Log.debug "Website Name: #{name}"
	Chef::Log.debug("Powershell Code----------------------")
	Chef::Log.debug(@powershell_code)
	
	exit_status = Chef::IISPOSH::Common_code.exit_code(script)
	if exit_status == 55
		Chef::Log.debug "Website successfully deleted: #{name}"
	elsif exit_status == 66
		raise "Error deleting Website: #{name}"
	else
		raise "Something happened while deleting the Website: #{name}"
	end	
end	


# Stop Website
def stop_website(my_current_resource)

	name		= "#{my_current_resource.name}"
			
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		Change-State -name "#{name}" -website -stop
		exit 55
		
	EOF
	Chef::Log.debug "Website Name: #{name}"
			
	exit_status = Chef::IISPOSH::Common_code.exit_code(script)
	if exit_status == 55
		Chef::Log.debug "Website successfully stopped: #{name}"
	elsif exit_status == 66
		raise "Error stopping Website: #{name}"
	else
		raise "Something happened while stopping the Website: #{name}"
	end	
end	

# Start Website
def start_website(my_current_resource)

	name		= "#{my_current_resource.name}"
			
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		Change-State -name "#{name}" -website -start
		exit 55
		
	EOF
	Chef::Log.debug "Website Name: #{name}"
		
	exit_status = Chef::IISPOSH::Common_code.exit_code(script)
	if exit_status == 55
		Chef::Log.debug "Website successfully started: #{name}"
	elsif exit_status == 66
		raise "Error starting Website: #{name}"
	else
		raise "Something happened while starting the Website: #{name}"
	end	
end	

# Retart Website
def restart_website(my_current_resource)

	name		= "#{my_current_resource.name}"
			
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$results = Restart-Webobject -name "#{name}" -website
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
		Chef::Log.debug "Website successfully Restarted: #{name}"
	elsif exit_status == 66
		raise "Error Restarting Website: #{name}"
	else
		raise "Something happened while Restarting the Website: #{name}"
	end	
end	

	
	