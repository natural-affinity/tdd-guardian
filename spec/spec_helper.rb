require 'simplecov'
SimpleCov.start

module GuardianSpecHelper
	def write_settings(project, guards, file = 'config/settings.yaml')
		config = project.merge(guards)

		File.delete(file) if File.exists?(file)
 		File.open(file, 'w') { |f| f.write(config.to_yaml) }   	
	end
end
