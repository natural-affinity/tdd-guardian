require 'thor/group'

class ProjectGenerator < Thor::Group
	include Thor::Actions

	class_option :clean, :type => :boolean, :default => false, :lazy_default => true
	class_option :target, :type => :string, :default => '.'

	def read_project_config
		@reader = ConfigurationReader.new
	end

	def create_project_dir
		dir = File.join(options[:target], @reader.project)
 	
 		remove_dir(dir) if (options[:clean] && File.exist?(dir))
		empty_directory(dir)
	end
end
