
windows_feature_manage_feature "#{cookbook_name}_install_Web_WHC_Feature" do
  feature_name "Web-WHC"
  action :install
end