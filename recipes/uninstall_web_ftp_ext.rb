
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_Ftp_Ext_Feature" do
  feature_name "Web-Ftp-Ext"
  action :remove
end