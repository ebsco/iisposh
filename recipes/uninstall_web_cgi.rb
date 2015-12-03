
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_Cgi_Feature" do
  feature_name "Web-CGI"
  action :remove
end