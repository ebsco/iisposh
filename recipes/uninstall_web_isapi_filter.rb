
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_ISAPI_Filter_Feature" do
  feature_name "Web-ISAPI-Filter"
  action :remove
end