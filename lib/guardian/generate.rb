require 'thor'

class Guardian::Generate < Thor
	include Thor::Actions

	class_option :file, :lazy_default => '', :aliases => '-f', :desc => "Config to use from #{Guardian::CONFIG_PATH}"

	attr_reader :util, :reader, :valid, :has_run

	def self.source_root
		Guardian::ROOT
	end

	desc 'all', 'Creates the project directory structure, Gemfile, and Guardfile from config'
	def all
		options[:init] = true
		project; gemfile; guardfile; runner
	end

	desc 'gemfile', 'Create the project Gemfile from <config>'
	def gemfile
		init_common_components
		write_template('Gemfile')
		@util.exec('bundle install', @reader.file, already_validated?)
	end

	desc 'guardfile', 'Create the project Guardfile from config'
	method_option :init, :type => :boolean, :aliases => '-i', :desc => 'Also guard init matchers to Guardfile'
	def guardfile
		inits = []
		init_common_components
		write_template('Guardfile')
		gemfile unless File.file?(@util.target(@reader.file, true, 'Gemfile'))

		@reader.guards.each do | g |
			inits.push @util.exec("bundle exec guard init #{g}", @reader.file, already_validated?)
		end unless @reader.guards.nil? || !options[:init]

		inits
	end

	desc 'project', 'Create the project directory structure from config'
	def project
		init_common_components
		return unless already_validated?

		write_directory('bin')
		write_directory('lib')
		write_directory('scripts')
		write_directory('features/step_definitions', @reader.guards.include?('cucumber'))
		write_directory('features/support', @reader.guards.include?('cucumber'))
		write_directory('spec', @reader.guards.include?('rspec'))
		write_directory('test', !@reader.guards.include?(%w[rspec cucumber]))
	end

	desc 'runner', 'Create a runner script start.sh to launch guard for the project'
	def runner
		init_common_components
		return unless already_validated?

		write_directory('scripts')
		write_template('start.sh', 'scripts')
		chmod(@util.target(@reader.file, true, 'scripts/start.sh'), 0755)
	end

	private

	def init_common_components
		@util = Guardian::Util.new

		unless already_validated?
			@reader = @util.invoke(Guardian::Config, options, 'validate').reader
			@valid = !@reader.has_errors?
		end

		initial_setup if !@has_run && already_validated?
	end

	def initial_setup
		@has_run = true
		target_dir = File.join(@reader.root, @reader.project)
		target_link = @util.target(@reader.file, true)

		empty_directory(target_dir) unless File.directory?(target_dir)
		FileUtils.rmdir(@util.target(@reader.file, true, nil, false)) unless File.directory?(target_link)
		create_link(target_link, target_dir)
	end

	def write_template(name, subpath = nil)
		path = subpath.nil? ? "#{name}" : "#{subpath}/#{name}"
		template("./#{Guardian::TEMPLATE}/#{name}.tt", @util.target(@reader.file, true, path)) if already_validated?
	end

	def write_directory(subpath, conditional = true)
		empty_directory(@util.target(@reader.file, true, subpath)) if conditional
	end

	def already_validated?
		!@valid.nil? && @valid
	end
end