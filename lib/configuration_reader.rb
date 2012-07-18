require 'yaml'

class ConfigurationReader
	attr_reader :yaml, :guards

	def initialize
		load
	end

	def load(dir = 'config', file = 'settings.yaml')
		path = File.join(Dir.pwd, dir, file)

		@yaml = YAML::load(File.open(path))
		@yaml.nil? == false		
	end

	def parse
		@guards = @yaml['guards']

	end

end
