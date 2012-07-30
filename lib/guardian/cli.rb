require 'thor'

# Primary Application Class which calls out to config and generate
# subcommand classes for the implemented functionality.
class Guardian::CLI < Thor
  # Allows the application version to be displayed via <app> --version in addition to <app> version
  map '--version' => 'version'

  # @!method config
  # Config subcommand (implemented via {Guardian::Config})
  desc 'config', 'Configuration file manipulation for project templates'
  subcommand 'config', Guardian::Config

  # @!method generate
  # Generate subcommand (implemented via {Guardian::Generate})
  desc 'generate', 'Project generation based on specified config and templates'
  subcommand 'generate', Guardian::Generate

  # @!method version
  # Displays application version and copyright information
  # @!visibility public
  desc '--version', 'Displays guardian application version details'
  def version
    say "#{Guardian::NAME} version #{Guardian::VERSION} \n#{Guardian::COPYRIGHT} \n"
  end
end
