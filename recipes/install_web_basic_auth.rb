
windows_feature_manage_feature "#{cookbook_name}_install_Web_Basic_Auth_Feature" do
  feature_name "Web-Basic-Auth"
  action :install
end