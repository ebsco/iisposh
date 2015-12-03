
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_Ftp_Service_Feature" do
  feature_name "Web-Ftp-Service"
  action :remove
end