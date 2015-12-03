
windows_feature_manage_feature "#{cookbook_name}_install_Web_ISAPI_Ext_Feature" do
  feature_name "Web-ISAPI-Ext"
  action :install
end