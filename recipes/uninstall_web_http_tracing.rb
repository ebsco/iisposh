
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_Http_Tracing_Feature" do
  feature_name "Web-Http-Tracing"
  action :remove
end