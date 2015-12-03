
windows_feature_manage_feature "#{cookbook_name}_install_Web_Windows_Auth_Feature" do
  feature_name "Web-Windows-Auth"
  action :install
end