
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_Net_Ext_Feature" do
  feature_name "Web-Net-Ext"
  action :remove
end