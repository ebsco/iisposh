
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_Dir_Browsing_Feature" do
  feature_name "Web-Dir-Browsing"
  action :remove
end