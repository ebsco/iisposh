
windows_feature_manage_feature "#{cookbook_name}_install_Web_Ftp_Service_Feature" do
  feature_name "Web-Ftp-Service"
  action :install
end