require 'yaml'

class Guardian::Reader

	attr_reader :data, :file, :supported

	def initialize(file = '', extensions = %w[.yaml .yaml.example])
		@file = get_filename(file)
		@supported = extensions

		load
	end

	private

	def load
		filename = File.join(Guardian::CONFIG_PATH, @file)
		@data = YAML::load(File.open(filename)) if File.file?(filename)
		@data = {} if @data.nil? || @data == false
	end

	def get_filename(filename)
		return filename if (filename.nil? || filename.empty?)

		filename << '.yaml' unless filename.end_with?(table_for(@supported))
		filename
	end

	def table_for(collection, *args)
		"Got #{collection} and #{args.join(',')}"
	end

end