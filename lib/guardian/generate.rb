require 'thor'

class Guardian::Generate < Thor
	include Thor::Actions

	attr_reader :reader, :gems

	def self.source_root
		Guardian::ROOT
	end

	class_option :file, :lazy_default => '', :aliases => '-f', :desc => "Config to use from #{Guardian::CONFIG_PATH}"
	class_option :clean, :type => :boolean, :aliases => '-c', :desc  => "Force overwrite of existing files and/or directories"

	desc 'all', 'Creates the project directory structure, Gemfile, and Guardfile from config'
	def all
		say_status :error, "Not Implemented Yet", :red

	end

	desc 'gemfile', 'Create the project Gemfile from <config>'
	def gemfile
		if config_is_valid?(Guardian::Config)
			target_dir = File.join(@reader.root, @reader.project)
			target_link = "./config/.#{@reader.file}.dir"

			empty_directory(target_dir) unless File.directory?(target_dir)
			build_gem_list

			FileUtils.rm_f(File.join(Guardian::CONFIG_PATH, "#{@reader.project}.dir"))
			create_link(target_link, target_dir)
			template('./templates/Gemfile.tt', "#{target_link}/Gemfile")
		end
	end

	desc 'guardfile', 'Create the project Guardfile from config'
	def guardfile
		say_status :error, "Not Implemented Yet", :red
	end

	desc 'project', 'Create the project directory structure from config'
	def project
		say_status :error, "Not Implemented Yet", :red
	end

	private

	def build_gem_list
		@gems = []

		@reader.guards.each do | guard |
			@gems.insert(0,"gem #{guard}, :groups => [:development, :test]") unless guard == 'bundler'
			@gems.push("gem guard-#{guard}, :groups => [:development, :test]")
		end unless @reader.guards.nil?
	end

	def config_is_valid? (config_class)
		instance = config_class.new
		instance.options = options
		instance.validate

		@reader = instance.reader
		!@reader.has_errors?
	end
end