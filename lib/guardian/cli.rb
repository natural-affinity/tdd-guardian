require 'thor'

class Guardian::CLI < Thor
	map '--version' => 'version'

	desc 'config', 'Configuration file manipulation for project templates'
	subcommand 'config', Guardian::Config

	desc '--version', 'Displays guardian application version details'
	def version
		say "#{Guardian::NAME} version #{Guardian::VERSION} \n#{Guardian::COPYRIGHT} \n"
	end

end
