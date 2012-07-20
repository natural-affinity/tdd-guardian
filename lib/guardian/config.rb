require 'thor'

class Guardian::Config < Thor

	desc 'list', 'Displays a list of available configuration files'
	def list
		files = get_config_list

    if files.empty?
    	say_status :error, "No configuration files found.", :red
    	say_status :solution, "Use the guardian <config> <generate> wizard for assistance", :blue
    else	
    	files.each { | f | say_status 'conf ', f, :yellow }
    end
	end

	desc 'validate', 'Validates the contents of a configuration file'
	method_option :file, :required => true, :lazy_default => '', :aliases => '-f'
	def validate
  	filename = options[:file]
  	is_valid = get_config_list.include?(filename)

  	unless is_valid
  		say_status :error, "No configuration file named '#{filename}' found", :red
  		say_status :solution, "Please use guardian <config> <list> for valid filenames"
  		say_status :solution, "Searching for configuration files in #{Guardian::CONFIG_PATH}", :blue
  		invoke :list, nil, [] 
  	end
	end

	private
	
	# Helper method to fetch a valid list of configuration files
	def get_config_list
    files = Dir.entries(Guardian::CONFIG_PATH)
    files.delete_if { | f | f.start_with?('.', Guardian::CONFIGURATION) }
    files.delete_if { | f | f.end_with?('.yaml', '.yaml.example') == false }
    files
	end
end
