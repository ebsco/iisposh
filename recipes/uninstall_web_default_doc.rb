
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_Default_Doc_Feature" do
  feature_name "Web-Default-Doc"
  action :remove
end