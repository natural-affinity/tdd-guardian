require 'yaml'

class ConfigurationReader

	def load(dir = 'config', file = 'settings.yaml')
		path = File.join(Dir.pwd, dir, file)
		yaml = YAML::load(File.open(path))

		yaml != nil		
	end
end
