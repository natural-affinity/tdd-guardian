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

	def write_settings(project, guards, file = 'config/settings.yaml', template = {'template' => nil})
		config = project.merge(guards).merge(template)

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
