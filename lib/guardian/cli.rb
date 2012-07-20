require 'thor'

class Guardian::CLI < Thor
	map '--version' => 'version'

	desc 'validate', 'Validates an existing configuration file'
	def validate
		raise 'Not Implemented Yet'
	end
	
	desc '--version', 'Displays guardian application version details'
	def version
		say "#{Guardian::NAME} version #{Guardian::VERSION} \n#{Guardian::COPYRIGHT} \n"
	end

end
