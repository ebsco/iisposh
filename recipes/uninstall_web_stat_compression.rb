
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_Stat_Compression_Feature" do
  feature_name "Web-Stat-Compression"
  action :remove
end