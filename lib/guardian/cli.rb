require 'thor'

class Guardian::CLI < Thor
	map '--version' => 'version'

	desc 'config', 'Configuration file manipulation for project templates'
	subcommand 'config', Guardian::Config

	desc 'generate', 'Project generation based on specified config and templates'
	subcommand 'generate', Guardian::Generate

	desc '--version', 'Displays guardian application version details'
	def version
		say "#{Guardian::NAME} version #{Guardian::VERSION} \n#{Guardian::COPYRIGHT} \n"
	end
end
