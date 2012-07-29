require 'yaml'
require 'simplecov'
SimpleCov.start

$0 = 'guardian'
ARGV.clear

module GuardianSpecHelper
	def capture(stream)
  	begin
    	stream = stream.to_s
    	eval "$#{stream} = StringIO.new"
    yield
    	result = eval("$#{stream}").string
  	ensure
    	eval("$#{stream} = #{stream.upcase}")
  	end
  	result
	end

	def create_capture_remove(std, options, file, settings = nil)
		# Create
		settings = {} if settings.nil?

		write_settings(settings[:project],
									 settings[:guards],
									 settings[:template],
									 settings[:root],
									 settings[:single_guards],
									 file)


		# Capture output
		output = capture(std) { Guardian::CLI.start(options) }

		# Remove
		FileUtils.rm_f([file])

		output
	end

	def run_cli(klass, options, command, command_return = false)
		cli = klass.new
		cli.options = options
		ret = cli.send(command)
		command_return ? ret : cli
	end

	def write_settings(project, guards, template, root, single_guards, file)
		project = {'project' => nil} if project.nil?
		template = {'template' => nil} if template.nil?
		guards = {'guards' => nil} if guards.nil?
		root = {'root' => nil} if root.nil?
		single_guards = [] if single_guards.nil?

		config = project.merge(guards).merge(template).merge(root)
		single_guards.each { |g| config = config.merge(g) } unless single_guards.empty?

		write_to_yaml(file, config)
	end

	def write_to_yaml(file, data)
		File.delete(file) if File.exists?(file)
		File.open(file, 'w') { |f| f.write(data.to_yaml) }
	end

	def create_folder(path)
		delete_folder(path)
		Dir.mkdir(path)
	end

	def delete_folder(path)
		if File.directory?(path)
			FileUtils.remove_dir(path, :force => true)
		else
			FileUtils.rm_rf(path) if File.exists?(path)
		end
	end

	def create_valid_config(file)
		project = {'project' => 'test'}
		template = {'template' => 'general'}
		guards = {'guards' => %w[bundler rspec cucumber haml]}
		root = {'root' => 'tmp'}
		single_guards = []
		single_guards.push({'bundler' => {'patterns' => [{'watch' => "'Gemfile'"}]}})
		single_guards.push({'rspec' => {'patterns' => [{'watch' => '%r{^spec/.+_spec\.rb$}', 'block' => '|m| "spec/#{m[1]}_spec.rb"'}]}})

		write_settings(project, guards, template, root, single_guards, file)
	end

	def get_test_path(path)
		"#{File.expand_path(path)}/test"
	end
end
