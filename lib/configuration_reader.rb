require 'yaml'

class ConfigurationReader
	attr_reader :yaml, :guards, :project

	def initialize
		parse if load
	end

	def load(dir = 'config', file = 'settings.yaml')
		path = File.join(Dir.pwd, dir, file)

		@yaml = YAML::load(File.open(path)) if File.exists?(path)
		@yaml.nil? == false		
	end

	def parse
		@guards = parse_with_default('guards', ['bundler'])
		@project = parse_with_default('project', 'new-project')
	end

	def parse_with_default(setting, default)
		value = @yaml[setting]
		value == nil ? default : @yaml[setting]	
	end
end
