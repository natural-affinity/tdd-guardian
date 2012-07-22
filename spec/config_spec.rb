require 'spec_helper'
require_relative '../lib/guardian'

describe Guardian::Config do
	include GuardianSpecHelper

	attr_accessor :cli

	before(:each) do
		@cli = Guardian::Config.new
	end

	it "should have the following subcommands" do
  	options = %w[config]	
		output = capture(:stdout) { Guardian::CLI.start(options) }
    output.should =~ /guardian config list/
		output.should =~ /guardian config validate/
	end

	context "guardian config list" do
  	it "should not list the settings.yaml internal config file" do
  		output = capture(:stdout) { @cli.list }
  		output.should_not =~ /settings.yaml/
  	end

		it "should not list any hidden files" do
    	hidden_file = File.join(Guardian::CONFIG_PATH, '.dotfile_test')
    	
    	FileUtils.touch(hidden_file)
    	output = capture(:stdout) { @cli.list }
    	output.should_not =~ /.dotfile_test/
    	
    	FileUtils.rm(hidden_file)
		end

    it "should only list files that end with .yaml or .yaml.example" do
    	yaml = File.join(Guardian::CONFIG_PATH, 'test_project.yaml')
    	example = File.join(Guardian::CONFIG_PATH, 'test_example.yaml.example')
			invalid = File.join(Guardian::CONFIG_PATH, 'test_invalid.yml')

    	FileUtils.touch([yaml, example, invalid])
    	output = capture(:stdout) { @cli.list }
    	output.should =~ /test_project.yaml/
    	output.should =~ /test_example.yaml.example/
    	output.should_not =~ /test_invalid.yml/
      
      FileUtils.rm([yaml, example, invalid])
    end

		it "should display a warning if no configuration files are found" do
    	output = capture(:stdout) { @cli.list }
    	output.include?("No configuration files found.").should == true
			output.include?("guardian <config> <generate>").should == true
		end
	end

	context "guardian config validate (no file)" do
  	it "should require a --file option" do
  		options = ["config", "validate"]
  		output = capture(:stderr) { Guardian::CLI.start(options) }
  	 	output.should =~ /No value provided for required options '--file'/
  	end

		it "should allow a -f alias for --file" do
			options = ['config', 'validate', '-f']
			output = capture(:stderr) { Guardian::CLI.start(options) }
  	 	output.should =~ /No value provided for required options '--file'/
		end

  	it "should display a warning if the filename is empty" do
    	options = ['config', 'validate', '--file=']
    	output = capture(:stdout) { Guardian::CLI.start(options) }
    	output.include?("No configuration file named '' found").should == true
  	end

		it "should display a warning and not allow paths in the filename" do
			options = ['config', 'validate', '--file=/blah']
			output = capture(:stdout) { Guardian::CLI.start(options) }
			output.include?("No configuration file named '/blah.yaml' found").should == true
		end

		it "should invoke guardian <config> <list> if no files found" do
    	config = File.join(Guardian::CONFIG_PATH, 'test.yaml')
      FileUtils.touch(config)

      options = ['config', 'validate', '--file=']
      output = capture(:stdout) { Guardian::CLI.start(options) }

			FileUtils.rm_f([config])
			output.include?("test.yaml").should == true
		end
	end

	context "guardian config validate (file)" do
		it "should auto add the yaml extension to the specified config file name" do
			config = File.join(Guardian::CONFIG_PATH, 'katana.yaml')
			FileUtils.touch(config)

			options = ['config', 'validate', '-f=katana']
			output = capture(:stdout) { Guardian::CLI.start(options) }

			FileUtils.rm_f([config])
			output.should_not =~ /No configuration file/
		end
	end

	context "guardian config validate (file) -- '.yaml' format validation" do
		it "should display a warning if the project name is not set" do
			config = File.join(Guardian::CONFIG_PATH, 'katana.yaml')
			project = {'project' => nil}
			guards = {'guards' => nil}
			write_settings(project, guards, config)

			options = ['config', 'validate', '-f=katana.yaml']
			output = capture(:stdout) { Guardian::CLI.start(options) }

			FileUtils.rm_f([config])
			output.should =~ /project name not set/
		end

		it "should display a success message with the project name if found" do
			config = File.join(Guardian::CONFIG_PATH, 'katana.yaml')
			project = {'project' => 'katana'}
			guards = {'guards' => nil}
			write_settings(project, guards, config)

			options = ['config', 'validate', '-f=katana.yaml']
			output = capture(:stdout) { Guardian::CLI.start(options) }

			FileUtils.rm_f([config])
			output.should =~ /project name 'katana' detected/
		end

		it "should display a warning no guards are specified" do
			config = File.join(Guardian::CONFIG_PATH, 'project_zero.yaml')
			project = {'project' => nil}
			guards = {'guards' => nil}
			write_settings(project, guards, config)

			options = ['config', 'validate', '-f=project_zero.yaml']
			output = capture(:stdout) { Guardian::CLI.start(options) }
			FileUtils.rm_f([config])
			output.should =~ /no guards specified/
		end

		it "should display a success message for each guard found" do
			config = File.join(Guardian::CONFIG_PATH, 'project_zero.yaml')
			project = {'project' => nil}
			guards = {'guards' => %w[bundler rspec]}
			write_settings(project, guards, config)

			options = ['config', 'validate', '-f=project_zero.yaml']
			output = capture(:stdout) { Guardian::CLI.start(options) }
			FileUtils.rm_f([config])
			output.should =~ /guard-bundler detected/
			output.should =~ /guard-rspec detected/
		end

		it "should display compound status messages" do
			config = File.join(Guardian::CONFIG_PATH, 'project_zero.yaml')
			project = {'project' => 'project_zero'}
			guards = {'guards' => nil}
			write_settings(project, guards, config)

			options = ['config', 'validate', '-f=project_zero.yaml']
			output = capture(:stdout) { Guardian::CLI.start(options) }
			FileUtils.rm_f([config])
			output.should =~ /project name 'project_zero' detected/
			output.should =~ /no guards specified/
		end

		it "should display a warning if no template is specified" do
			config = File.join(Guardian::CONFIG_PATH, 'project_zero.yaml')
			project = {'project' => nil}
			guards = {'guards' => nil}
			template = {'template' => nil}
			write_settings(project, guards, config, template)

			options = ['config', 'validate', '-f=project_zero']
			output = capture(:stdout) { Guardian::CLI.start(options) }

			FileUtils.rm_r([config])
			output.should =~ /no project template type specified/
		end

		it "should display a success message if the 'custom' template is specified" do
			config = File.join(Guardian::CONFIG_PATH, 'project_zero.yaml')
			project = {'project' => nil}
			guards = {'guards' => nil}
			template = {'template' => 'custom'}
			write_settings(project, guards, config, template)

			options = ['config', 'validate', '-f=project_zero']
			output = capture(:stdout) { Guardian::CLI.start(options) }

			FileUtils.rm_r([config])
			output.should =~ /project template type 'custom' detected/
		end

		it "should display a success message if an unsupported template type is specified" do
			config = File.join(Guardian::CONFIG_PATH, 'project_zero.yaml')
			project = {'project' => nil}
			guards = {'guards' => nil}
			template = {'template' => 'merb'}
			write_settings(project, guards, config, template)

			options = ['config', 'validate', '-f=project_zero']
			output = capture(:stdout) { Guardian::CLI.start(options) }

			FileUtils.rm_r([config])
			output.should =~ /unsupported template type 'merb' detected/
		end

	end

end
