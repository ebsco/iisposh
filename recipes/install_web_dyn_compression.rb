
windows_feature_manage_feature "#{cookbook_name}_install_Web_Dyn_Compression_Feature" do
  feature_name "Web-Dyn-Compression"
  action :install
end