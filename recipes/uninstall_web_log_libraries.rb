
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_Log_Libraries_Feature" do
  feature_name "Web-Log-Libraries"
  action :remove
end