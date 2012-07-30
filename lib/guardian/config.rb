require 'thor'
require 'yaml'

# Config subcommand class used to invoke and display the results of config file validation
class Guardian::Config < Thor

  # Instance of the {Guardian::Reader} class
  attr_reader :reader

  # @!method list
  # Displays a list of available configuration files or an error message on (STDOUT)
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

  # @!method generate
  # Runs the config generation wizard to help build a valid config file via prompts displays on (STDOUT)
  desc 'generate', 'Wizard to help generate a skeleton configuration file'
  def generate
    say_status :error, "Not Implemented Yet", :red
  end

  # @!method validate
  # Validates each component of the config file and displays a status message for each on (STDOUT)
  desc 'validate', 'Validates the contents of a configuration file'
  method_option :file, :required => true, :lazy_default => '', :aliases => '-f'
  def validate
    @util = Guardian::Util.new
    @reader = Guardian::Reader.new(options[:file])

    unless @reader.has_config?
      say_status :error, "No configuration file named '#{@reader.file}' found", :red
      say_status :solution, "Please use guardian <config> <list> for valid filenames", :blue
      say_status :info, "Searching for configuration files in #{Guardian::CONFIG_PATH}", :yellow
      invoke :list, nil, []
      return
    end

    @util.display_status('project name', @reader.project, @reader.errors[Guardian::Reader::PROJECT])
    @util.display_status('project template type', @reader.template, @reader.errors[Guardian::Reader::TEMPLATE])
    @util.display_status('project installation directory', @reader.root, @reader.errors[Guardian::Reader::ROOT])
    @util.display_status('guard', @reader.guards, @reader.errors[Guardian::Reader::GUARDS])
    display_pattern_status(@util, @reader.guards, @reader.errors)
  end

  private

  # @!method display_pattern_status(util, guards, errors)
  # @param [Guardian::Util] util an instance of the util class for consistent display formatting
  # @param [Array<String>] guards a list of guards for which to check for valid patterns
  # @param [Hash<String, String>] errors errors from the underlying {Guardian::Reader} class to use in display
  def display_pattern_status(util, guards, errors)
    guards.each do | g |
      value = errors[g] == nil ? 'valid patterns' : nil
      util.display_status("guard-#{g}", value, "guard-#{g} #{errors[g]}", false)
    end unless guards.nil?
  end
end
