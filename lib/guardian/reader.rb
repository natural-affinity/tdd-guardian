require 'yaml'

class Guardian::Reader
	ROOT = 'root'
	GUARDS = 'guards'
	PROJECT = 'project'
	TEMPLATE = 'template'
	PATTERNS = 'patterns'

	ROOT_ERROR = 'project installation directory does not exist'
	GUARD_ERROR = 'no guards specified'
	PROJECT_ERROR = 'project name not specified'
	TEMPLATE_ERROR = 'project template type is unsupported'
	PATTERN_ERROR = 'has invalid pattern(s) (ensure each has a watch, optionally a block)'

	attr_reader :available, :file, :data, :project, :template, :root, :guards, :patterns, :errors

	def initialize(file = '')
		@file = get_filename(file)
		@errors = {}
		@available = Guardian::Reader::get_available_config

		load unless @available.empty?
	end

	def self.get_available_config
		files = Dir.entries(Guardian::CONFIG_PATH)
		files.delete_if { | f | f.start_with?('.') || f == Guardian::CONFIGURATION }
		files.delete_if { | f | !f.end_with?('.yaml') }
		files
	end

	def has_config?
		@available.include?(@file)
	end

	def has_errors?
		!@errors.empty? || !has_config?
	end

	private

	def load
		@data = YAML::load(File.open(File.join(Guardian::CONFIG_PATH, @file))) if self.has_config?
		@data = {} if @data.nil? || @data == false

		parse_root(@data[ROOT])
		parse_project(@data[PROJECT])
		parse_template(@data[TEMPLATE])
		parse_guards(@data[GUARDS])
		parse_patterns
	end

	def parse_project(name)
		@errors[PROJECT] = PROJECT_ERROR if name.nil? || !name.is_a?(String)
		@project = name unless @errors[PROJECT]
	end

	def parse_template(type)
		@errors[TEMPLATE] = TEMPLATE_ERROR unless Guardian::SUPPORTED_TEMPLATES.include?(type)
		@template = type unless @errors[TEMPLATE]
	end

	def parse_root(folder)
		@errors[ROOT] = ROOT_ERROR if folder.nil? || !File.directory?(File.expand_path(folder))
		@root = File.expand_path(folder) unless @errors[ROOT]
	end

	def parse_guards(guards)
		@errors[GUARDS] = GUARD_ERROR if guards.nil? || !guards.is_a?(Array)
		@guards = guards unless @errors[GUARDS]
	end

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

	def get_filename(filename)
		return '' if filename.nil?

		filename << '.yaml' unless filename.end_with?('.yaml')
		filename
	end
end