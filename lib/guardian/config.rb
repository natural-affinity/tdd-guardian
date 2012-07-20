require 'thor'

class Guardian::Config < Thor

	desc 'list', 'Displays a list of available configuration files'
	def list
		files = Dir.entries(Guardian::CONFIG_PATH)
    files.delete_if { | f | f.start_with?('.', Guardian::CONFIGURATION) }
    files.delete_if { | f | f.end_with?('.yaml', '.yaml.example') == false }
      
    if files.empty?
    	say "No configuration files found.", :red
    	say "Use the guardian <config> <generate> wizard for assistance", :blue
    else	
    	files.each { | f | say f, :yellow }
    end
	end

end
