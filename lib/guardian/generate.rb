require 'thor'

class Guardian::Generate < Thor
	include Thor::Actions

	class_option :file, :lazy_default => '', :aliases => '-f', :desc => "Config to use from #{Guardian::CONFIG_PATH}"
	class_option :clean, :type => :boolean, :aliases => '-c', :desc  => "Force overwrite of existing files and/or directories"

	attr_reader :reader, :valid

	def self.source_root
		Guardian::ROOT
	end

	desc 'all', 'Creates the project directory structure, Gemfile, and Guardfile from config'
	def all
		say_status :error, "Not Implemented Yet", :red
	end

	desc 'gemfile', 'Create the project Gemfile from <config>'
	def gemfile
		setup_project('Gemfile.tt', 'Gemfile')
	end

	desc 'guardfile', 'Create the project Guardfile from config'
	def guardfile
		setup_project('Guardfile.tt', 'Guardfile')
	end

	desc 'project', 'Create the project directory structure from config'
	def project
		say_status :error, "Not Implemented Yet", :red
	end

	private

	def setup_project(src_name, target_name)
		if validate_has_run? || config_is_valid?
			target_dir = File.join(@reader.root, @reader.project)
			target_link = "./config/.#{@reader.file}.dir"

			# Create Project Directory
			empty_directory(target_dir) unless File.directory?(target_dir)

			# Create Link to Project Directory
			FileUtils.rm_f(File.join(Guardian::CONFIG_PATH, ".#{@reader.file}.dir"))
			create_link(target_link, target_dir)

			# Create from Template
			template("./templates/#{src_name}", "#{target_link}/#{target_name}")
		end
	end

	def config_is_valid?
		config = Guardian::Config.new
		config.options = options
		config.validate

		@reader = config.reader
		@valid = !@reader.has_errors?
	end

	def validate_has_run?
		!@valid.nil? && @valid
	end
end