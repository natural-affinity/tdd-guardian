require 'thor/group'

class ProjectGenerator < Thor::Group
	include Thor::Actions

	attr_accessor :gems
	class_option :clean, :type => :boolean, :default => false, :lazy_default => true
	class_option :target, :type => :string, :default => '.'

	def self.source_root
    File.dirname('.')
  end

	def read_project_config
		@reader = ConfigurationReader.new
	end

	def create_project_dir
		dir = File.join(options[:target], @reader.project)
 	
 		remove_dir(dir) if (options[:clean] && File.exist?(dir))
		empty_directory(dir)
	end

	def create_gemfile
		guards = ['bundler', 'haml', 'rspec']
    @gems = []

		guards.each do | guard |
			@gems.push("gem #{guard}, :groups => [:development, :test]") unless guard == 'bundler'
			@gems.push("gem guard-#{guard}, :groups => [:development, :test]")
		end

		template('templates/Gemfile.tt', 'gemtest')	
	end
end
