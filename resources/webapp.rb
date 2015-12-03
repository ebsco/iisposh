actions :create, :config, :delete

default_action :create

# Name of the webapp
attribute :name,				:kind_of => String
# Location of webapp
attribute :path,				:kind_of => String
# Name of webapp Application Pool
attribute :pool,				:kind_of => String
# Name of webapp parent site
attribute :site,				:kind_of => String
# Hash webapp properties
attribute :properties,			:kind_of => Hash

attr_accessor :exists
attr_accessor :configured