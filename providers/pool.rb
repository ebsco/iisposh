use_inline_resources

def load_current_resource

	require 'mixlibrary/core/apps/shell'
	
	@current_resource = Chef::Resource::IisposhPool.new(@new_resource.name)
	@current_resource.name(@new_resource.name)
	@current_resource.properties(@new_resource.properties)
	@powershell_code = Chef::IISPOSH::Common_code.ps_code(@new_resource.properties)
end

# Create Action
action :create do
	@current_resource.exists = false
	if pool_exists(@current_resource) 
		@current_resource.exists = true
	end	
	if @current_resource.exists
		Chef::Log.debug("Not running Converged Action")
	else
		create_pool(@new_resource)
		Chef::Log.debug("Running Converged Action ..................................")
		@new_resource.updated_by_last_action(true)
	end
	
	
end

# Config Action
action :config do
	@current_resource.exists = false
	@current_resource.configured = false
	if pool_exists(@current_resource) 
		@current_resource.exists = true
		if pool_configured(@current_resource) 
			@current_resource.configured = true
		end	
	end	
  if !@current_resource.exists
    Chef::Log.debug("Not running Converged Action as AppPool doesnt exist")
		raise "Unable to Configure Application Pool - Pool doesn't Exist!"
	elsif @current_resource.configured 
		Chef::Log.debug("Not running Converged Action")
	else
		config_pool(@new_resource)
		Chef::Log.debug("Running Converged Action ..................................")
		Chef::Log.debug("Pool Properties - HASH ----------------------------------------")
		Chef::Log.debug(@new_resource.properties)
		@new_resource.updated_by_last_action(true)
	end
end

# Delete Action
action :delete do
	@current_resource.exists = false
	if pool_exists(@current_resource) 
		@current_resource.exists = true
	end	
	if !@current_resource.exists
		Chef::Log.debug("Not running Converged Action")
	else
		delete_pool(@new_resource)
		Chef::Log.debug("Running Converged Action ..................................")
		@new_resource.updated_by_last_action(true)
	end
	

end

# Stop Action
action :stop do

	@current_resource.exists = false
	@current_resource.running = false
	if pool_exists(@current_resource) 
		@current_resource.exists = true
		if pool_running(@current_resource) 
			@current_resource.running = true
		end	
	end	
	if !@current_resource.exists
		Chef::Log.debug("Not running converge action")
		raise "Unable to stop application pool - Pool doesn't exist!"
	elsif !@current_resource.running
		Chef::Log.debug("Not running converge action")
	else	
		stop_pool(@new_resource)
		Chef::Log.debug("Running Converged Action ..................................")
		@new_resource.updated_by_last_action(true)				
	end
end

# Start Action
action :start do

	@current_resource.exists = false
	@current_resource.running = false
	if pool_exists(@current_resource) 
		@current_resource.exists = true
		if pool_running(@current_resource) 
			@current_resource.running = true
		end	
	end	
	if !@current_resource.exists 
		Chef::Log.debug("Not running converge action")
		raise "Unable to start Application Pool - Pool Doesn't Exist"
	elsif @current_resource.running
		Chef::Log.debug("Not running converge action")
	else	
		start_pool(@new_resource)
		Chef::Log.debug("Running Converged Action ..................................")
		@new_resource.updated_by_last_action(true)				
	end
end

# Restart Action
action :restart do

	@current_resource.exists = false
	@current_resource.running = false
	if pool_exists(@current_resource) 
		@current_resource.exists = true
	end	
	if !@current_resource.exists
		Chef::Log.debug("Not running converge action")
		raise "Unable to restart Application Pool - Pool doesn't exist!"
	else	
		restart_pool(@new_resource)
		Chef::Log.debug("Running Converged Action ..................................")
		@new_resource.updated_by_last_action(true)				
	end
end

# Check if Pool Exists
def pool_exists(my_current_resource)
	
	name		= "#{my_current_resource.name}"
				
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$results = Pool-Exists -name "#{name}" 
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
		Chef::Log.debug "Application Pool Exists: #{name}"
		return true
	elsif exit_status == 66
		Chef::Log.debug "Application Pool Doesn't Exist: #{name}"
		return false
	else
		raise "Something happened Checking for Pool: #{name}"
	end	
	
end

# Configure Pool
def pool_configured(my_current_resource)
	
	name		= "#{my_current_resource.name}"
	
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$results = Check-PoolProperties -name "#{name}" -myhash #{@powershell_code} 
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

# Check if Pool is running
def pool_running(my_current_resource)
	
	name		= "#{my_current_resource.name}"
				
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$results = Get-Runningstate -name "#{name}" -pool
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
		Chef::Log.debug "Pool is Running: #{name}"
		return true
	elsif exit_status == 66
		Chef::Log.debug "Pool is Stopped: #{name}"
		return false
	else
		raise "Something happened Checking for Pool State: #{name}"
	end	
end


# Create Application Pool
def create_pool(my_current_resource)

	name			= "#{my_current_resource.name}"
		
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$results = New-Pool -name "#{name}" -myhash #{@powershell_code} 
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
	Chef::Log.debug("powershell_code----------------------")
	Chef::Log.debug(@powershell_code)
	
	exit_status = Chef::IISPOSH::Common_code.exit_code(script)
	
	if exit_status == 55
		Chef::Log.debug "Application Pool successfully created: #{name}"
	elsif exit_status == 66
		raise "Error Creating Application Pool"
	else
		raise "Something happened while Creating the Pool"
	end	
end	


# Config Pool
def config_pool(my_current_resource)

	name			= "#{my_current_resource.name}"
		
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$results = Config-Pool -name "#{name}" -myhash #{@powershell_code} 
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
	Chef::Log.debug("powershell_code----------------------")
	Chef::Log.debug(@powershell_code)
	
		
	exit_status = Chef::IISPOSH::Common_code.exit_code(script)
	
	if exit_status == 55
		Chef::Log.debug "Application Pool Properties successfully set: #{name}"
	elsif exit_status == 66
		raise "Error setting Application Pool Properties"
	else
		raise "Something happened while Configuring the Pool"
	end	
end	

# Delete Pool
def delete_pool(my_current_resource)
	name			= "#{my_current_resource.name}"
		
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$results = Delete-Pool -name "#{name}" 
		
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
		Chef::Log.debug "Application Pool Successfully Deleted: #{name}"
	elsif exit_status == 66
		raise "Error Deleting Application Pool"
	else
		raise "Something happened while Deleting the Pool"
	end	
end
	
# Stop Pool
def stop_pool(my_current_resource)

	name		= "#{my_current_resource.name}"
			
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		Change-State -name "#{name}" -pool -stop
		exit 55
		
	EOF
	Chef::Log.debug "Pool Name: #{name}"
			
	exit_status = Chef::IISPOSH::Common_code.exit_code(script)
	
	if exit_status == 55
		Chef::Log.debug "Application Pool successfully stopped: #{name}"
	elsif exit_status == 66
		raise "Error stopping Application Pool: #{name}"
	else
		raise "Something happened while stopping the Application Pool: #{name}"
	end	
end	

# Start Pool
def start_pool(my_current_resource)

	name		= "#{my_current_resource.name}"
			
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		Change-State -name "#{name}" -pool -start
		exit 55
	EOF
	Chef::Log.debug "Pool Name: #{name}"
			
	exit_status = Chef::IISPOSH::Common_code.exit_code(script)
	
	if exit_status == 55
		Chef::Log.debug "Application Pool successfully started: #{name}"
	elsif exit_status == 66
		raise "Error starting Application Pool: #{name}"
	else
		raise "Something happened while starting the Application Pool: #{name}"
	end	
end	

# Retart/Recycle Pool
def restart_pool(my_current_resource)

	name		= "#{my_current_resource.name}"
			
	script = <<-EOF
		. #{node['iisposh']['ps_path']}
		$results = Restart-Webobject -name "#{name}" -pool
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
		Chef::Log.debug "Application Pool successfully Restarted: #{name}"
	elsif exit_status == 66
		raise "Error Restarting Application Pool: #{name}"
	else
		raise "Something happened while Restarting the Application Pool: #{name}"
	end	
end	


	
	