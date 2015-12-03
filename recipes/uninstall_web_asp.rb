
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_ASP_Feature" do
  feature_name "Web-ASP"
  action :remove
end