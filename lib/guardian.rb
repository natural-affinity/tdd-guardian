# Serves as the wrapper module for the entire application
# Includes app-level constants and loads all component classes
module Guardian

  # Application Name
  NAME = 'Guardian'

  # Application Version
  VERSION = '0.1.62'

  # Application Copyright
  COPYRIGHT = 'Copyright (C) 2012 Rizwan Tejpar'

  # Application Configuration Filename
  CONFIGURATION = 'settings.yaml'

  # Application Source Directory Name
  LIB = 'lib'

  # Application Temporary Directory Name
  TEMP = 'tmp'

  # Application Config Directory Name
  CONFIG = 'config'

  # Application Template Directory Name
  TEMPLATE = 'templates'

  # Application Root Directory (Absolute Path)
  ROOT = File.expand_path('.')

  # Application Temp Directory (Absolute Path)
  TEMP_PATH = "#{ROOT}/#{TEMP}"

  # Application Config Directory (Absolute Path)
  CONFIG_PATH = "#{ROOT}/#{CONFIG}"

  # Application Template Directory (Absolute Path)
  TEMPLATE_PATH = "#{ROOT}/#{TEMPLATE}"

  # Application Supported Template Types
  SUPPORTED_TEMPLATES = %w[general]

  # Application Supported Config file extensions
  SUPPORTED_CONFIG_EXTENSIONS = %w[.yaml]

  # Load Guardian Classes
  autoload :Util, "#{ROOT}/#{LIB}/guardian/util"
  autoload :Reader, "#{ROOT}/#{LIB}/guardian/reader"
  autoload :Config, "#{ROOT}/#{LIB}/guardian/config"
  autoload :Generate, "#{ROOT}/#{LIB}/guardian/generate"
  autoload :CLI, "#{ROOT}/#{LIB}/guardian/cli"
end
