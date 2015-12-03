
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_Asp_Net_Feature" do
  feature_name "Web-Asp-Net"
  action :remove
end