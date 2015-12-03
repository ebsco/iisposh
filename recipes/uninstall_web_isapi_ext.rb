windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_ISAPI_Ext_Feature" do
  feature_name "Web-ISAPI-Ext"
  action :remove
end