
windows_feature_manage_feature "#{cookbook_name}_install_Web_Lgcy_Mgmt_Feature" do
  feature_name "Web-Lgcy-Mgmt-Console"
  action :install
end