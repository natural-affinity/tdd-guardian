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

	def write_settings(project, guards, template, root, single_guards, file)
		project = {'project' => nil} if project.nil?
		template = {'template' => nil} if template.nil?
		guards = {'guards' => nil} if guards.nil?
		root = {'root' => nil} if root.nil?
		single_guards = [] if single_guards.nil?

		config = project.merge(guards).merge(template).merge(root)
		single_guards.each { |g| config = config.merge(g) } unless single_guards.empty?

		File.delete(file) if File.exists?(file)
		File.open(file, 'w') { |f| f.write(config.to_yaml) }
	end

	def create_folder(path)
		delete_folder(path)
		Dir.mkdir(path)
	end

	def delete_folder(path)
		FileUtils.rm_rf(path) if File.exists?(path)
	end
end
