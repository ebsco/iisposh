
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_Client_Auth_Feature" do
  feature_name "Web-Client-Auth"
  action :remove
end