
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_Request_Monitor_Feature" do
  feature_name "Web-Request-Monitor"
  action :remove
end