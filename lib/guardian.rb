module Guardian

	# Internal Application Information
	NAME = 'Guardian'
	VERSION = '0.1.39'
	COPYRIGHT = 'Copyright (C) 2012 Rizwan Tejpar'	
	CONFIGURATION = 'settings.yaml'

	# General Paths
	ROOT = File.expand_path('.')
	TEMP_PATH = "#{ROOT}/tmp"
	CONFIG_PATH = "#{ROOT}/config"
	TEMPLATE_PATH = "#{ROOT}/templates"

	# General Extensions
	CONFIG_EXTENSIONS = %w[.yaml .yaml.example]

	# Load Guardian Classes
	autoload :Reader, "#{ROOT}/lib/guardian/reader"
	autoload :Config, "#{ROOT}/lib/guardian/config"
	autoload :CLI, "#{ROOT}/lib/guardian/cli"
end
