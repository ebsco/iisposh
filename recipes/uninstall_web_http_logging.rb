
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_Http_Logging_Feature" do
  feature_name "Web-Http-Logging"
  action :remove
end