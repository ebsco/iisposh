
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_Includes_Feature" do
  feature_name "Web-Includes"
  action :remove
end