require 'thor'

# Generate subcommand class used to create Gemfile, Guardfile, Directory, and Runner project artifacts
class Guardian::Generate < Thor
  include Thor::Actions

  class_option :file, :lazy_default => '', :aliases => '-f', :desc => "Config to use from #{Guardian::CONFIG_PATH}"

  attr_reader :util, :reader, :valid, :has_run

  # Adds the {Guardian::ROOT} directory to the class source path for Thor
  def self.source_root
    Guardian::ROOT
  end

  # @!method all
  # Creates all project artifacts.  Invoke with -i, --init option to also include (guard init) defaults in Guardfile
  desc 'all', 'Creates the project directory structure, Gemfile, and Guardfile from config'
  method_option :init, :type => :boolean, :aliases => '-i', :desc => 'Also guard init matchers to Guardfile'
  def all
    project
    gemfile if has_run
    guardfile if has_run
    runner if has_run
  end

  # @!method gemfile
  # Creates the Gemfile for the project.  Also invokes 'bundle install' to install the desired gems.
  desc 'gemfile', 'Create the project Gemfile from <config>'
  def gemfile
    return unless init_common_components

    write_template('Gemfile')
    @util.exec('bundle install', @reader.file, already_validated?)
  end

  # @!method guardfile
  # Creates the Guardfile for the project. Invoke with -i, --init option to also include (guard init) defaults.
  desc 'guardfile', 'Create the project Guardfile from config'
  method_option :init, :type => :boolean, :aliases => '-i', :desc => 'Also guard init matchers to Guardfile'
  def guardfile
    inits = []
    return unless init_common_components

    write_template('Guardfile')
    gemfile unless File.file?(@util.target(@reader.file, true, 'Gemfile'))

    @reader.guards.each do | g |
      inits.push @util.exec("bundle exec guard init #{g}", @reader.file, already_validated?)
    end unless @reader.guards.nil? || !options[:init]

    inits
  end

  # @!method project
  # Creates the directory structure for the project.
  desc 'project', 'Create the project directory structure from config'
  def project
    return unless init_common_components

    write_directory('bin')
    write_directory('lib')
    write_directory('scripts')
    write_directory('features/step_definitions', @reader.guards.include?('cucumber'))
    write_directory('features/support', @reader.guards.include?('cucumber'))
    write_directory('spec', @reader.guards.include?('rspec'))
    write_directory('test', !@reader.guards.include?('rspec') && !reader.guards.include?('cucumber'))
  end

  # @!method runner
  # Creates the runner script for the project.
  desc 'runner', 'Create a runner script start.sh to launch guard for the project'
  def runner
    return unless init_common_components

    write_directory('scripts')
    write_template('start.sh', 'scripts')
    chmod(@util.target(@reader.file, true, 'scripts/start.sh'), 0755)
  end

  private

  # @!method init_common_components
  # Invokes dependencies required by all tasks (i.e. config validation, project root directory setup)
  # @see #initial_setup
  # @return [true, false] true if the config file has no errors, false otherwise
  def init_common_components
    @util = Guardian::Util.new

    unless already_validated?
      @reader = @util.invoke(Guardian::Config, options, 'validate').reader
      @valid = !@reader.has_errors?
    end

    initial_setup if !@has_run && already_validated?
    already_validated?
  end

  # @!method initial_setup
  # Performs parent directory setup (i.e. <root>/<project name>) and symlinks the directory within {Guardian::CONFIG}
  def initial_setup
    @has_run = true
    target_dir = File.join(@reader.root, @reader.project)
    target_link = @util.target(@reader.file, true)

    empty_directory(target_dir) unless File.directory?(target_dir)
    FileUtils.rmdir(@util.target(@reader.file, true, nil, false)) unless File.directory?(target_link)
    create_link(target_link, target_dir)
  end

  # @!method write_template(name, subpath = nil)
  # Invokes the Thor template task with the specified template name, and creates the target artifact file
  # @param [String] name Template name within {Guardian::TEMPLATE} without '.tt' extension
  # @param [String, nil] subpath Target artifact to generate as {Guardian::CONFIG}/.(link).dir/(subpath)/(name)
  def write_template(name, subpath = nil)
    path = subpath.nil? ? "#{name}" : "#{subpath}/#{name}"
    template("./#{Guardian::TEMPLATE}/#{name}.tt", @util.target(@reader.file, true, path)) if already_validated?
  end

  # @!method write_directory(subpath, conditional = true)
  # Creates the desired project subdirectory if the desired condition is met
  # @param [subpath] subpath subdirectory within <root>/<project name> to create
  # @param [true, false] conditional result of an optional conditional to determine if the directory should be created
  def write_directory(subpath, conditional = true)
    empty_directory(@util.target(@reader.file, true, subpath)) if conditional
  end

  # @!method already_validated?
  # A convenience method to determine if the config file has already been validated.
  # Used to avoid un-necessary re-validation.
  # @return [true, false] true if the config file is valid, false otherwise
  def already_validated?
    !@valid.nil? && @valid
  end
end
