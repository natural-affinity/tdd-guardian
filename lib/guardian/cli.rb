require 'thor'

class Guardian::CLI < Thor
	map '--version' => 'version'

	desc 'version', 'Displays Guardian application version details'
	def version
		say "#{Guardian::NAME} version #{Guardian::VERSION} \n#{Guardian::COPYRIGHT} \n"
	end

end