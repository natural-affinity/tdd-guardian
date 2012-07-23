require 'yaml'

class Guardian::Reader
	ROOT = 'root'
	GUARDS = 'guards'
	PROJECT = 'project'
	TEMPLATE = 'template'
	PATTERNS = 'patterns'

	attr_reader :available, :file, :data, :project, :template, :root, :guards, :patterns, :errors

	def initialize(file = '')
		@file = get_filename(file)
		@errors = {}
		@available = get_available_config

		load unless @available.empty?
	end

	private

	def load
		path = File.join(Guardian::CONFIG_PATH, @file)
		@data = YAML::load(File.open(path)) if @available.include?(@file)
		@data = {} if @data.nil? || @data == false

		parse_root(@data[ROOT])
		parse_project(@data[PROJECT])
		parse_template(@data[TEMPLATE])
		parse_guards(@data[GUARDS])
		parse_patterns
	end

	def parse_project(name)
		@errors[PROJECT] = true if name.nil? || !name.is_a?(String)
		@project = name unless @errors[PROJECT]
	end

	def parse_template(type)
		@errors[TEMPLATE] = true unless Guardian::SUPPORTED_TEMPLATES.include?(type)
		@template = type unless @errors[TEMPLATE]
	end

	def parse_root(folder)
		@errors[ROOT] = true if folder.nil? || !File.directory?(folder)
		@root = folder unless @errors[ROOT]
	end

	def parse_guards(guards)
		@errors[GUARDS] = true if guards.nil? || !guards.is_a?(Array)
		@guards = guards unless @errors[GUARDS]
	end

	def parse_patterns
		@patterns = {}

		unless @guards.nil?
			@guards.each do | g |

				unless @data[g].nil?
					guard_pattern = @data[g][PATTERNS].nil? ? [] : @data[g][PATTERNS]
					pattern_count = guard_pattern.length

					guard_pattern.delete_if { | p | p['watch'].nil?}
					@errors[g] = true if pattern_count != 0 && pattern_count != guard_pattern.length
					patterns[g] = guard_pattern unless guard_pattern.empty?
				end
			end
		end

		@patterns = nil if patterns.empty?
	end

	def has_errors?
		!@errors.empty?
	end

	def get_filename(filename)
		return '' if filename.nil?

		filename << '.yaml' unless filename.end_with?('.yaml', '.yaml.example')
		filename
	end

	def get_available_config
		files = Dir.entries(Guardian::CONFIG_PATH)
		files.delete_if { | f | f.start_with?('.') || f == Guardian::CONFIGURATION }
		files.delete_if { | f | !f.end_with?('.yaml', '.yaml.example') }
		files
	end
end