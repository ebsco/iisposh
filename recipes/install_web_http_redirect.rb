
windows_feature_manage_feature "#{cookbook_name}_install_Web_Http_Redirect_Feature" do
  feature_name "Web-Http-Redirect"
  action :install
end