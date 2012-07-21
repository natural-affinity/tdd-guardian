require 'thor'
require 'yaml'

class Guardian::Config < Thor
	PROJECT_NAME = 'project'


	desc 'list', 'Displays a list of available configuration files'
	def list
		files = get_config_list

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
  	filename = get_filename(options[:file])
  	is_valid = get_config_list.include?(filename)

  	unless is_valid
  		say_status :error, "No configuration file named '#{filename}' found", :red
  		say_status :solution, "Please use guardian <config> <list> for valid filenames"
  		say_status :solution, "Searching for configuration files in #{Guardian::CONFIG_PATH}", :blue
  		invoke :list, nil, []
		  return
		end

		path = File.join(Guardian::CONFIG_PATH, filename)
		yaml = YAML::load(File.open(path))
		yaml = {} if (yaml.nil? || yaml == false)

		validate_project(yaml[PROJECT_NAME])
 	end

	private

	def get_filename(filename)
		return filename if (filename.nil? || filename.empty?)

		filename << '.yaml' unless filename.include?('.yaml')
		filename
	end

	# Helper method to fetch a valid list of configuration files
	def get_config_list
    files = Dir.entries(Guardian::CONFIG_PATH)
    files.delete_if { | f | f.start_with?('.') || f == Guardian::CONFIGURATION }
    files.delete_if { | f | !f.end_with?('.yaml', '.yaml.example') }
    files
	end

	def validate_project(name)
		if name.nil?
			say_status :warn, "project name not set", :yellow
		else
		  say_status :success, "project name '#{name}' detected", :green
		end
	end
end
