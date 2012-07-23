require 'thor'
require 'yaml'

class Guardian::Config < Thor
	ROOT = 'root'
	PROJECT = 'project'
	GUARDS = 'guards'
	TEMPLATE = 'template'
	PATTERNS = 'patterns'
	WATCH_PATTERN = 'watch'
	BLOCK_PATTERN = 'block'

	desc 'list', 'Displays a list of available configuration files'
	def list
		files = get_config_list

    if files.empty?
    	say_status :error, "No configuration files found.", :red
    	say_status :solution, "Use the guardian <config> <generate> wizard for assistance", :blue
    else	
    	files.each { | f | say_status :found, f, :yellow }
    end
	end

	desc 'validate', 'Validates the contents of a configuration file'
	method_option :file, :required => true, :lazy_default => '', :aliases => '-f'
	def validate
  	filename = get_filename(options[:file])
  	is_valid = get_config_list.include?(filename)

  	unless is_valid
  		say_status :error, "No configuration file named '#{filename}' found", :red
  		say_status :solution, "Please use guardian <config> <list> for valid filenames", :blue
  		say_status :info, "Searching for configuration files in #{Guardian::CONFIG_PATH}", :yellow
  		invoke :list, nil, []
		  return
		end

		path = File.join(Guardian::CONFIG_PATH, filename)
		yaml = YAML::load(File.open(path))
		yaml = {} if (yaml.nil? || yaml == false)

		validate_project(yaml[PROJECT])
		validate_template(yaml[TEMPLATE])
		validate_root(yaml[ROOT])
		validate_guards(yaml[GUARDS])
		validate_guard_patterns(yaml[GUARDS], yaml) unless yaml[GUARDS].nil?

 	end

	private

	def get_filename(filename)
		return filename if (filename.nil? || filename.empty?)

		filename << '.yaml' unless filename.include?('.yaml')
		filename
	end

	# Helper method to fetch a valid list of configuration files
	def get_config_list
    files = Dir.entries(Guardian::CONFIG_PATH)
    files.delete_if { | f | f.start_with?('.') || f == Guardian::CONFIGURATION }
    files.delete_if { | f | !f.end_with?('.yaml', '.yaml.example') }
    files
	end

	def validate_project(name)
		if name.nil?
			say_status :warn, "project name not specified", :yellow
		else
		  say_status :info, "project name '#{name}' detected", :green
		end
	end

	def validate_guards(guards)
		if guards.nil?
			say_status :warn, "no guards specified", :yellow
		else
			guards.each { | g | say_status :info, "guard-#{g} detected", :green}
		end
	end

	def validate_template(template)
		supported = 'general'

		if template.nil?
			say_status :warn, "project template type not specified", :yellow
		else
			if template == supported
				say_status :info, "project template type '#{supported}' detected", :green
			else
				say_status :warn, "project template type '#{template}' is unsupported", :yellow
			end
		end
	end

	def validate_root(root)
		if root.nil? || File.exists?(root)
			say_status :warn, "project installation directory does not exist", :yellow
		else
			say_status :info, "project installation root #{File.expand_path(root)} detected", :green
		end
	end

	def validate_guard_patterns(guards, yaml)
		guards.each do | name, value |

			patterns = yaml[name].nil? ? nil : yaml[name]['patterns']
			has_pattern(name, patterns)
		end
	end

	def has_pattern(name, patterns)
		return say_status(:warn, "guard-#{name} has no watch and block pattern(s) specified", :yellow) if patterns.nil?
		all_valid = true

		patterns.each do | pattern |

			if pattern['watch'].nil? || pattern['block'].nil?
				say_status :warn, "guard-#{name} has an invalid pattern: watch='#{pattern['watch']}' block='#{pattern['block']}'", :yellow
				all_valid = false
			end
		end

		say_status :info, "guard-#{name} has valid patterns", :green if all_valid
	end

end