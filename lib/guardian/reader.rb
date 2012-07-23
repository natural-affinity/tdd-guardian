require 'yaml'

class Guardian::Reader

	attr_reader :available, :file, :data, :project, :template, :root, :guards

	def initialize(file = '')
		@file = get_filename(file)
		@available = get_available_config

		load unless @available.empty?
	end

	private

	def load
		path = File.join(Guardian::CONFIG_PATH, @file)
		@data = YAML::load(File.open(path)) if @available.include?(@file)
		@data = {} if @data.nil? || @data == false

		parse
	end

	def get_available_config
		files = Dir.entries(Guardian::CONFIG_PATH)
		files.delete_if { | f | f.start_with?('.') || f == Guardian::CONFIGURATION }
		files.delete_if { | f | !f.end_with?('.yaml', '.yaml.example') }
		files
	end

	def get_filename(filename)
		return '' if filename.nil?

		filename << '.yaml' unless filename.end_with?('.yaml', '.yaml.example')
		filename
	end

	def parse
		@project = @data['project']
		@guards = @data['guards']
		@template = @data['template'] if %w[general].include?(@data['template'])
		@root = @data['root'] if File.exist?(@data['root']) unless @data['root'].nil? || File.file?(@data['root'])
	end
end