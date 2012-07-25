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

	desc 'validate', 'Validates the contents of a configuration file'
	method_option :file, :required => true, :lazy_default => '', :aliases => '-f'
	def validate
		@reader = Guardian::Reader.new(options[:file])

  	unless @reader.has_config?
  		say_status :error, "No configuration file named '#{reader.file}' found", :red
  		say_status :solution, "Please use guardian <config> <list> for valid filenames", :blue
  		say_status :info, "Searching for configuration files in #{Guardian::CONFIG_PATH}", :yellow
  		invoke :list, nil, []
		  return
		end

		display_status('project name', @reader.project, @reader.errors[Guardian::Reader::PROJECT])
		display_status('project template type', @reader.template, @reader.errors[Guardian::Reader::TEMPLATE])
		display_status('project installation directory', @reader.root, @reader.errors[Guardian::Reader::ROOT])
		display_status('guard', @reader.guards, @reader.errors[Guardian::Reader::GUARDS])
		display_pattern_status(@reader.guards, @reader.errors)
	end

	private

	def display_pattern_status(guards, errors)
		guards.each do | g |
			display_status("guard-#{g}", errors[g] == nil ? 'valid patterns' : nil, "guard-#{g} #{errors[g]}")
		end unless guards.nil?
	end

	def display_status(start, value, error)
		state = error && value.nil? ? :warn : :info
		color = error && value.nil? ? :yellow : :green

		if !value.nil? && value.is_a?(Array)
			value.each do | v |
				say_status state, "#{start}-#{v} detected", color
			end
		else
			message = value.nil? ? error : "#{start} '#{value}' detected"
			say_status state, message, color
		end
	end
end