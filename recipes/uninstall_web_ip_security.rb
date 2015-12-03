
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_IP_Security_Feature" do
  feature_name "Web-IP-Security"
  action :remove
end