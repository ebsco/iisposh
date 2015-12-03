
windows_feature_manage_feature "#{cookbook_name}_install_Web_Dav_Publishing_Feature" do
  feature_name "Web-Dav-Publishing"
  action :install
end