require 'thor'

class Guardian::Util < Thor
	include Thor::Actions

	no_tasks do

		def display_status(start, value, error, quoted = true)
			state = error && value.nil? ? :warn : :info
			color = error && value.nil? ? :yellow : :green

			if !value.nil? && value.is_a?(Array)
				value.each { |v| say_status state, "#{start}-#{v} detected", color }
			else
				value = "'#{value}'" if quoted && !value.nil?
				message = value.nil? ? error : "#{start} #{value} detected"
				say_status state, message, color
			end
		end

		def exec(command, link, condition = true, opts = {:verbose => true})
			ret = false
			inside(target(link, true)) { ret = run(command, opts) } if condition

			ret
		end

		def invoke(klass, opt, command)
			instance = klass.new
			instance.options = opt
			instance.send(command)
			instance
		end

		def target(link, as_directory = false, subpath = nil, relative = true)
			dir = relative ? "./#{Guardian::CONFIG}/" : "#{Guardian::CONFIG_PATH}/"
			path = ".#{link}.dir"
			path.insert(0, dir) if as_directory
			path << "/#{subpath}" unless subpath.nil?
			path
		end
	end
end