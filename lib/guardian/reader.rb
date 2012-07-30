require 'yaml'

# Underlying class that parses and validates the Guardian project config file format
class Guardian::Reader

  # Name of the project root directory element in the config file
  ROOT = 'root'

  # Name of the guards element in the config file
  GUARDS = 'guards'

  # Name of the project element in the config file
  PROJECT = 'project'

  # Name of the project template element in the config file
  TEMPLATE = 'template'

  # Name of the patterns element in the config file
  PATTERNS = 'patterns'

  # The error message for an invalid root directory
  ROOT_ERROR = 'project installation directory does not exist'

  # The error message for invalid guards
  GUARD_ERROR = 'no guards specified'

  # The error message for an invalid project name
  PROJECT_ERROR = 'project name not specified'

  # The error message for an invalid project template
  TEMPLATE_ERROR = 'project template type is unsupported'

  # The error message for invalid guard patterns
  PATTERN_ERROR = 'has invalid pattern(s) (ensure each has a watch, optionally a block)'

  attr_reader :available, :file, :data, :project, :template, :root, :guards, :patterns, :errors

  # @!method initialize(file = '')
  # Loads the desired config file (if available) and validates it on construct
  # @see #load
  # @param [String] file the name of the the config file to load
  # @return [Guardian::Reader] an instance of the {Guardian::Reader} class
  def initialize(file = '')
    @file = get_filename(file)
    @errors = {}
    @available = Guardian::Reader::get_available_config

    load unless @available.empty?
  end

  # @!method get_available_config
  # Gets a list of recognized configuration files (i.e. any visible <config>.yaml file in {Guardian::CONFIG})
  # @return [Array<String>] a list of config files in {Guardian::CONFIG}
  def self.get_available_config
    files = Dir.entries(Guardian::CONFIG_PATH)
    files.delete_if { | f | f.start_with?('.') || f == Guardian::CONFIGURATION }
    files.delete_if { | f | !f.end_with?('.yaml') }
    files
  end

  # @!method has_config?
  # A convenience method to determine if the desired config file is recognized (i.e. available for use)
  # @return [true, false] true if recognized, false otherwise
  def has_config?
    @available.include?(@file)
  end

  # @!method has_errors?
  # A convenience method to determine if the desired config file has parsing errors or is not recognized
  # @return [true, false] true if available and valid, false otherwise
  def has_errors?
    !@errors.empty? || !has_config?
  end

  private

  # @!method load
  # Loads the project configuration file (YAML) and invokes the validation parsers
  # @see #parse_root
  # @see #parse_project
  # @see #parse_template
  # @see #parse_guards
  # @see #parse_patterns
  def load
    @data = YAML::load(File.open(File.join(Guardian::CONFIG_PATH, @file))) if self.has_config?
    @data = {} if @data.nil? || @data == false

    parse_root(@data[ROOT])
    parse_project(@data[PROJECT])
    parse_template(@data[TEMPLATE])
    parse_guards(@data[GUARDS])
    parse_patterns
  end

  # @!method parse_project(name)
  # Determines if the project name in the config file is valid.
  # Sets project attribute if valid; appends to the error attribute otherwise
  # @param [String] name project name to validate
  def parse_project(name)
    @errors[PROJECT] = PROJECT_ERROR if name.nil? || !name.is_a?(String)
    @project = name unless @errors[PROJECT]
  end

  # @!method parse_template(type)
  # Determines if the project template in the config file is valid (against the supported types).
  # Sets template attribute if valid; appends to the error attribute otherwise
  # @param [String] type project template type to validate
  def parse_template(type)
    @errors[TEMPLATE] = TEMPLATE_ERROR unless Guardian::SUPPORTED_TEMPLATES.include?(type)
  @template = type unless @errors[TEMPLATE]
  end

  # @!method parse_root(folder)
  # Determines if the project installation root directory in the config file is valid (i.e. exists)
  # Sets the root attribute if valid, appends to the error attribute otherwise
  # @param [String] folder path to installation root directory
  def parse_root(folder)
    @errors[ROOT] = ROOT_ERROR if folder.nil? || !File.directory?(File.expand_path(folder))
    @root = File.expand_path(folder) unless @errors[ROOT]
  end

  # @!method parse_guards(guards)
  # Determines if the guards in the config file are valid (i.e. at least one guard is specified)
  # @param [Array<String>] guards the list of guard names
  def parse_guards(guards)
    @errors[GUARDS] = GUARD_ERROR if guards.nil? || !guards.is_a?(Array)
    @guards = guards unless @errors[GUARDS]
  end

  # @!method parse_patterns
  # Determines if the patterns for each guard in the config file are valid (i.e. watch or watch-block)
  def parse_patterns
    @patterns = {}

      @guards.each do | g |
        unless @data[g].nil?
          guard_pattern = @data[g][PATTERNS].nil? ? [] : @data[g][PATTERNS]
          pattern_count = guard_pattern.length

          guard_pattern.delete_if { | p | p['watch'].nil?}
          @errors[g] = PATTERN_ERROR if pattern_count != 0 && pattern_count != guard_pattern.length
          patterns[g] = guard_pattern unless guard_pattern.empty?
        end
      end unless @guards.nil?

    @patterns = nil if patterns.empty?
  end

  # @!method get_filename(filename)
  # Gets the name of the config file (appends the .yaml extension if not specified for convenience)
  # @param [String, nil] filename name of the config file
  # @return [String] re-constructed config file name
  def get_filename(filename)
    return '' if filename.nil?

    filename << '.yaml' unless filename.end_with?('.yaml')
    filename
  end
end
