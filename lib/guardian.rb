module Guardian

	# Internal Application Information
	NAME = 'Guardian'
	VERSION = '0.1.33'
	COPYRIGHT = 'Copyright (C) 2012 Rizwan Tejpar'	
	CONFIGURATION = 'settings.yaml'

	# General Paths
	ROOT = File.expand_path('.')
	TEMP_PATH = "#{ROOT}/tmp"
	CONFIG_PATH = "#{ROOT}/config"
	TEMPLATE_PATH = "#{ROOT}/templates"

	# Load Guardian Classes
	autoload :Config, "#{ROOT}/lib/guardian/config"
	autoload :CLI, "#{ROOT}/lib/guardian/cli"
end
