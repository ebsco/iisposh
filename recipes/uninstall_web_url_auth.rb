
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_Url_Auth_Feature" do
  feature_name "Web-Url-Auth"
  action :remove
end