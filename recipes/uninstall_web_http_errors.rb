# Calling this recipe will require a reboot after it is run. 
# Handling it should be done by the cookbook calling this recipe.
#
# For more information see: https://docs.chef.io/resource_reboot.html


windows_feature_manage_feature "#{cookbook_name}_uninstall_Web_Http_Errors_Feature" do
  feature_name "Web-Http-Errors"
  action :remove
end


