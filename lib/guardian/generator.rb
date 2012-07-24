require 'thor/group'

class Guardian::Generator < Thor::Group
	include Thor::Actions

	desc "description for entire class"


	class_option :clean, :type => :boolean, :default => false, :lazy_default => true
	class_option :target, :type => :string, :default => '.'

	def self.source_root
    File.dirname(__FILE__)
  end

	def self.subcommand_help(name = Guardian::Generator)

	end
end
