
windows_feature_manage_feature "#{cookbook_name}_install_Web_WMI_Feature" do
  feature_name "Web-WMI"
  action :install
end