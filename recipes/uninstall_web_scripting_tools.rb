
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_Scripting_Tools_Feature" do
  feature_name "Web-Scripting-Tools"
  action :remove
end