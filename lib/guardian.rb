module Guardian

	# Internal Application Information
	NAME = 'Guardian'
	VERSION = '0.1.59'
	COPYRIGHT = 'Copyright (C) 2012 Rizwan Tejpar'	
	CONFIGURATION = 'settings.yaml'

	# Directories
	LIB = 'lib'
	TEMP = 'tmp'
	CONFIG = 'config'
	TEMPLATE = 'templates'

	# General Paths
	ROOT = File.expand_path('.')
	TEMP_PATH = "#{ROOT}/#{TEMP}"
	CONFIG_PATH = "#{ROOT}/#{CONFIG}"
	TEMPLATE_PATH = "#{ROOT}/#{TEMPLATE}"

	# Supported
	SUPPORTED_TEMPLATES = %w[general]
	SUPPORTED_CONFIG_EXTENSIONS = %w[.yaml]

	# Load Guardian Classes
	autoload :Util, "#{ROOT}/#{LIB}/guardian/util"
	autoload :Reader, "#{ROOT}/#{LIB}/guardian/reader"
	autoload :Config, "#{ROOT}/#{LIB}/guardian/config"
	autoload :Generate, "#{ROOT}/#{LIB}/guardian/generate"
	autoload :CLI, "#{ROOT}/#{LIB}/guardian/cli"
end
