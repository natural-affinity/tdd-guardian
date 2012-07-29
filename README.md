Guardian
=========
This application serves as a skeleton generator for 
setting up fully automated TDD project templates using 
Guard.  It allows one to start with a red-green refactor
cycle with Growl notifications (via gntp) from the get-go.

Prerequisites
-------------
* Bundler Gem 1.2.0.rc (gem install bundler --pre)
* Growl/Growlnotify 1.3+ (or gntp compatible equivalent)

Supported Platforms
-------------------
* Mac OSX
* Linux

Available Templates
-------------------
* General

Usage and documentation
-----------------------
Guardian is a command line application. Please open a terminal to your tdd-guardian root directory.

### Help

You can get a description of available tasks by invoking the 'help' task:  
```bash
$ ./bin/guardian help
```

You can get a description of avaialble sub-tasks by invoking the 'help' task after the parent task:  
```bash
$ ./bin/guardian generate help
```

### Config

* Guardian creates a skeleton project structure based on the YAML config file you specify.
* Configuration files should be stored in: '\<tdd-guardian-root\>/config' with a .yaml extension
* See 'config/sample.yaml.example' for sample values with comments

You can obtain a list of existing config files in the config directory as follows:  
```bash
$ ./bin/guardian config list
```

You can determine if you configuration file is valid as follows:  
```bash
$ ./bin/guardian config validate -f, --file=config
```

### Generate

* Guardian can help to generate a Gemfile, Guardfile, directory structure, and runner
* The Guardfile can be generated with guard-init defaults or only with custom patterns from your config
* The project directory structure is based on common ruby practices
* The runner serves as shell script to invoke guard and/or other project depenencies (e.g. web server)

You can generate all project artifacts as follows:  
```bash
$ ./bin/guardian generate all -f, --file=config -i, --init
```

You can generate the Gemfile exclusively using:  
```bash
$ ./bin/guardian generate gemfile -f, --file=config
```

You can generate the Guardfile exclusively using:  
```bash
$ ./bin/guardian generate guardfile -f, --file=config -i, --init
```

You can generate the project directory structure exclusively using:  
```bash
$ ./bin/guardian generate project -f, --file=config
```

You can generate the runner exclusively using:  
```bash
$ ./bin/guardian generate runner -f, --file=config
```

License
-------
Released under the MIT License.  See the LICENSE file for further details.
