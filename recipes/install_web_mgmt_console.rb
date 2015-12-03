
windows_feature_manage_feature "#{cookbook_name}_install_Web_Mgmt_Feature" do
  feature_name "Web-Mgmt-Console"
  action :install
end