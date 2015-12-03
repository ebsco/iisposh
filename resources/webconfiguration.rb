actions :config


default_action :config

# Hash Pool Properties
attribute :filter,			:kind_of => String
attribute :properties,			:kind_of => Hash
attribute :name,				:kind_of => String


attr_accessor :exists, :configured
