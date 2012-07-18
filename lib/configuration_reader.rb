require 'yaml'

class ConfigurationReader
	attr_reader :yaml

	def initialize
		@yaml = load
	end

	def load(dir = 'config', file = 'settings.yaml')
		path = File.join(Dir.pwd, dir, file)

		@yaml = YAML::load(File.open(path))
		@yaml.nil? == false		
	end
end
