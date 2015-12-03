actions :create, :config, :delete, :stop, :start, :restart

default_action :create

# Name of the website
attribute :name,				:kind_of => String
# Location of website
attribute :path,				:kind_of => String
# Name of Application Pool
attribute :pool,				:kind_of => String
# Hash Variables
attribute :properties,			:kind_of => Hash
# Binding Array
attribute :bindings,			:kind_of => Array, :default => ['']





attr_accessor :exists
attr_accessor :configured
attr_accessor :running