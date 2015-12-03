
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_Filtering_Feature" do
  feature_name "Web-Filtering"
  action :remove
end