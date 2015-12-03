#
# Cookbook Name:: iisposh
# Recipe:: iis_pool
#
# Copyright 2015, Ebsco
#
# All rights reserved - Do Not Redistribute

include_recipe 'iisposh::default'


# Application Pool Action - create, config, delete, start, stop
iisposh_pool 'pool' do 
	name "DemoPool2"
	properties(
			"recycling.periodicRestart.privatememory" => 4,
			"processmodel.maxprocesses" => 3,
			"managedPipeLineMode" => "Integrated",
			"managedRunTimeVersion" => "v2.0",
			"processModel.IdentityType" => "NetworkService",
			"autostart" => "True",
			"processmodel.pingingenabled" => "true",
			"enable32BitAppOnWin64" => "false",
			"processmodel.username" => "",
			"processmodel.password"	=> "",
			"recycling.logEventOnRecycle" => "Time,Requests,IsapiUnhealthy,OnDemand,ConfigChange"	
	)
	
	action :create
end


