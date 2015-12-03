
windows_feature_manage_feature "#{cookbook_name}_install_Web_Digest_Auth_Feature" do
  feature_name "Web-Digest-Auth"
  action :install
end