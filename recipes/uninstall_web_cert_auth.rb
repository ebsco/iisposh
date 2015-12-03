
windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_Cert_Auth_Feature" do
  feature_name "Web-Cert-Auth"
  action :remove
end