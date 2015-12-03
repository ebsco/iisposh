
windows_feature_manage_feature "#{cookbook_name}_install_Web_Filtering_Feature" do
  feature_name "Web-Filtering"
  action :install
end