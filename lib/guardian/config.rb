require 'thor'

class Guardian::Config < Thor

	desc 'list', 'Displays a list of available configuration files'
	def list
		files = Dir.entries(Guardian::CONFIG_PATH)
    files.delete_if { | f | f.start_with?('.', Guardian::CONFIGURATION) }
    files.delete_if { | f | f.end_with?('.yaml', '.yaml.example') == false }
      
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
  	if options[:file].empty? || options[:file].include?(File::SEPARATOR)
  		say_status :error, "No configuration file named '#{options[:file]}' found", :red
  		say_status :solution, "Searching for configuration files in #{Guardian::CONFIG_PATH}", :blue
  		invoke :list, nil, [] 
  	end
	end

end
