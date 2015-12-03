
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_Lgcy_Scripting_Feature" do
  feature_name "Web-Lgcy-Scripting"
  action :remove
end