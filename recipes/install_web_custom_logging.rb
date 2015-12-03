
windows_feature_manage_feature "#{cookbook_name}_install_Web_Custom_Logging_Feature" do
  feature_name "Web-Custom-Logging"
  action :install
end