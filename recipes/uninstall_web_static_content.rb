
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_Static_Content_Feature" do
  feature_name "Web-Static-Content"
  action :remove
end