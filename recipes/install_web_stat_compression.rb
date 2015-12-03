
windows_feature_manage_feature "#{cookbook_name}_install_Web_Stat_Compression_Feature" do
  feature_name "Web-Stat-Compression"
  action :install
end