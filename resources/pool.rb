actions :create, :config, :delete, :start, :stop, :restart


default_action :create

# Name of the Pool
attribute :name,				:kind_of => String
# Hash Pool Properties
attribute :properties,			:kind_of => Hash




attr_accessor :exists, :configured, :running
