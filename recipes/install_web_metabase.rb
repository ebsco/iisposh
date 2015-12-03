
windows_feature_manage_feature "#{cookbook_name}_install_Web_Metabase_Feature" do
  feature_name "Web-Metabase"
  action :install
end