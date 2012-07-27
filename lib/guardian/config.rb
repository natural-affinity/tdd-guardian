require 'thor'
require 'yaml'

class Guardian::Config < Thor

	attr_reader :reader

	desc 'list', 'Displays a list of available configuration files'
	def list
		files = Guardian::Reader::get_available_config

    if files.empty?
    	say_status :error, "No configuration files found.", :red
    	say_status :solution, "Use the guardian <config> <generate> wizard for assistance", :blue
    else	
    	files.each { | f | say_status :found, f, :yellow }
    end
	end

	desc 'generate', 'Wizard to help generate a skeleton configuration file'
	def generate
		say_status :error, "Not Implemented Yet", :red
	end

	desc 'validate', 'Validates the contents of a configuration file'
	method_option :file, :required => true, :lazy_default => '', :aliases => '-f'
	def validate
		@util = Guardian::Util.new
		@reader = Guardian::Reader.new(options[:file])

  	unless @reader.has_config?
  		say_status :error, "No configuration file named '#{@reader.file}' found", :red
  		say_status :solution, "Please use guardian <config> <list> for valid filenames", :blue
  		say_status :info, "Searching for configuration files in #{Guardian::CONFIG_PATH}", :yellow
  		invoke :list, nil, []
		  return
		end

		@util.display_status('project name', @reader.project, @reader.errors[Guardian::Reader::PROJECT])
		@util.display_status('project template type', @reader.template, @reader.errors[Guardian::Reader::TEMPLATE])
		@util.display_status('project installation directory', @reader.root, @reader.errors[Guardian::Reader::ROOT])
		@util.display_status('guard', @reader.guards, @reader.errors[Guardian::Reader::GUARDS])
		display_pattern_status(@util, @reader.guards, @reader.errors)
	end

	private

	def display_pattern_status(util, guards, errors)
		guards.each do | g |
			value = errors[g] == nil ? 'valid patterns' : nil
			util.display_status("guard-#{g}", value, "guard-#{g} #{errors[g]}", false)
		end unless guards.nil?
	end
end
