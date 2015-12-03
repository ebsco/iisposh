
windows_feature_manage_feature "#{cookbook_name}_install_Web_OD_Feature" do
  feature_name "Web-ODBC-Logging"
  action :install
end