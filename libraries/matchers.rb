if defined? ChefSpec
  [:create, :config, :delete, :stop, :start, :restart].each do |action|
    define_method "#{action}_iisposh_website" do |resource_name|
      ChefSpec::Matchers::ResourceMatcher.new('iisposh_website', action, resource_name)
    end
  end
  def config_iisposh_webconfiguration(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new('iisposh_webconfiguration', 'config', resource_name)
  end
  [:create, :config, :delete].each do |action|
    define_method "#{action}_iisposh_webapp" do |resource_name|
      ChefSpec::Matchers::ResourceMatcher.new('iisposh_webapp', action, resource_name)
    end
  end
  [:create, :config, :delete].each do |action|
    define_method "#{action}_iisposh_vdir" do |resource_name|
      ChefSpec::Matchers::ResourceMatcher.new('iisposh_vdir', action, resource_name)
    end
  end
  [:create, :config, :delete, :stop, :start, :restart].each do |action|
    define_method "#{action}_iisposh_pool" do |resource_name|
      ChefSpec::Matchers::ResourceMatcher.new('iisposh_pool', action, resource_name)
    end
  end
end
