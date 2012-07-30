require 'thor'

# Utility class of helper methods for Guardian tasks
class Guardian::Util < Thor
  include Thor::Actions

    no_tasks {
    # @!method display_status(start, value, error, quoted = true)
    # Displays a status message using consistent formatting and coloration
    # @param [String] start a common string to append at the start of the status message (e.g. 'project name')
    # @param [String, nil] value the string to display as the message body (or nil if error is set)
    # @param [String, nil] error the string to display as the message body (or nil if value is set)
    # @param [true, false] quoted a flag indicating if 'value' should appear in single quotes
    # @return displays the desired status message on {STDOUT}
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

    # @!method exec(command, link, condition = true, opts = {:verbose => true})
    # Executes the desired command inside the linked target folder
    # @param [String] command a system command to be executed
    # @param [String] link the name of the subfolder in which to perform the command
    # @param [true, false] condition a condition by which the command should or should not be executed
    # @param [Hash<Symbol=>Object>] opts Thor options to pass to the command during execution
    # @return [true, false] the result of command execution
    def exec(command, link, condition = true, opts = {:verbose => true})
      ret = false
      inside(target(link, true)) { ret = run(command, opts) } if condition

      ret
    end

    # @!method invoke(klass, opt, command)
    # Instantiates the desired class (with options) and invokes the desired task (command)
    # @param [class] klass the desired Thor subclass to instantiate
    # @param [Hash] opt options to pass to the subclass during invocation
    # @param [String] command the task (method name) to invoke within the subclass
    # @return [class] an instance of the invoked class
    def invoke(klass, opt, command)
      instance = klass.new
      instance.options = opt
      instance.send(command)
      instance
    end

    # @!method target(link, as_directory = false, subpath = nil, relative = true)
    # Builds a relative or absolute path string as follows: (config dir)/.(link).dir/(subpath)
    # @param [String] link the name of the linked project directory
    # @param [true, false] as_directory an optional flag indicating if the (config dir) path prefix should be included
    # @param [String, nil] subpath an optional filename or directory subpath to append
    # @param [true, false] relative an optional flag indiciating if the path should be relative or absolute
    # @return [String] the assembled path
    def target(link, as_directory = false, subpath = nil, relative = true)
      dir = relative ? "./#{Guardian::CONFIG}/" : "#{Guardian::CONFIG_PATH}/"
      path = ".#{link}.dir"
      path.insert(0, dir) if as_directory
      path << "/#{subpath}" unless subpath.nil?
      path
    end
    }
end
