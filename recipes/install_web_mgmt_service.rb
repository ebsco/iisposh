
windows_feature_manage_feature "#{cookbook_name}_install_Web_Mgmt_Service_Feature" do
  feature_name "Web-Mgmt-Service"
  action :install
end