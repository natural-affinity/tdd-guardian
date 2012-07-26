require 'thor'

class Guardian::Generate < Thor
	include Thor::Actions

	class_option :file, :lazy_default => '', :aliases => '-f', :desc => "Config to use from #{Guardian::CONFIG_PATH}"

	attr_reader :reader, :valid, :has_run

	def self.source_root
		Guardian::ROOT
	end

	desc 'all', 'Creates the project directory structure, Gemfile, and Guardfile from config'
	def all
		project; gemfile; guardfile
	end

	desc 'gemfile', 'Create the project Gemfile from <config>'
	def gemfile
		build_common_components
		write_template('Gemfile')
		exec_inside('bundle install')
	end

	desc 'guardfile', 'Create the project Guardfile from config'
	method_option :init, :type => :boolean, :aliases => '-i', :desc => 'Also guard init matchers to Guardfile'
	def guardfile
		inits = []
		build_common_components
		write_template('Guardfile')
		gemfile unless File.file?("./config/.#{@reader.file}.dir/Gemfile")

		@reader.guards.each do | g |
			inits.push exec_inside("bundle exec guard init #{g}")
		end unless @reader.guards.nil? || !options[:init]

		inits
	end

	desc 'project', 'Create the project directory structure from config'
	def project
		build_common_components
		return unless already_validated?

		write_directory('bin')
		write_directory('lib')
		write_directory('scripts')
		write_directory('features/step_definitions', @reader.guards.include?('cucumber'))
		write_directory('features/support', @reader.guards.include?('cucumber'))
		write_directory('spec', @reader.guards.include?('rspec'))
		write_directory('test', !@reader.guards.include?(%w[rspec cucumber]))
	end

	private

	def build_common_components
		validate_config unless already_validated?
		initial_setup if !@has_run && !@reader.has_errors?
	end

	def write_template(name)
		template("./templates/#{name}.tt", "./config/.#{@reader.file}.dir/#{name}") if already_validated?
	end

	def write_directory(subpath, conditional = true)
		empty_directory("./config/.#{@reader.file}.dir/#{subpath}") if conditional
	end

	def initial_setup
		@has_run = true
		target_dir = File.join(@reader.root, @reader.project)
		target_link = "./config/.#{@reader.file}.dir"

		empty_directory(target_dir) unless File.directory?(target_dir)

		FileUtils.rmdir(File.join(Guardian::CONFIG_PATH, ".#{@reader.file}.dir")) unless File.directory?(target_link)
		create_link(target_link, target_dir)
	end

	def validate_config
		config = Guardian::Config.new
		config.options = options
		config.validate

		@reader = config.reader
		@valid = !@reader.has_errors?
	end

	def already_validated?
		!@valid.nil? && @valid
	end

	def exec_inside(command)
		ret = false
		inside "./config/.#{@reader.file}.dir" do
			ret = run(command, {:verbose => false})
		end if already_validated?

	  ret
	end
end