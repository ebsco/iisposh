
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_WMI_Feature" do
  feature_name "Web-WMI"
  action :remove
end