require_relative '../spec_helper'
require_relative '../../lib/guardian'

describe Guardian::Config do
	include GuardianSpecHelper

	attr_accessor :cli, :options, :config

	before(:all) do
		@config = File.join(Guardian::CONFIG_PATH, 'test.yaml')
	end

	before(:each) do
		@cli = Guardian::Config.new
		@options = %w[config validate]
	end

	context "guardian config validate (no file)" do
		it "should require a --file option" do
			output = capture(:stderr) { Guardian::CLI.start(@options) }
			output.should =~ /No value provided for required options '--file'/
		end

		it "should allow a -f alias for --file" do
			@options.push('-f')
			output = capture(:stderr) { Guardian::CLI.start(@options) }
			output.should =~ /No value provided for required options '--file'/
		end

		it "should display a warning if the filename is empty" do
			@options.push('--file=')
			output = capture(:stdout) { Guardian::CLI.start(@options) }
			output.include?("No configuration file named '' found").should == true
		end

		it "should display a warning and not allow paths in the filename" do
			@options.push('--file=/blah')
			output = capture(:stdout) { Guardian::CLI.start(@options) }
			output.include?("No configuration file named '/blah.yaml' found").should == true
		end

		it "should invoke guardian <config> <list> if no files found" do
			FileUtils.touch(@config)

			@options.push('--file=')
			output = capture(:stdout) { Guardian::CLI.start(@options) }

			FileUtils.rm_f([@config])
			output.include?("test.yaml").should == true
		end
	end

	context "guardian config validate (file)" do
		it "should auto add the yaml extension to the specified config file name" do
			FileUtils.touch(@config)

			@options.push('-f=test')
			output = capture(:stdout) { Guardian::CLI.start(@options) }

			FileUtils.rm_f([@config])
			output.should_not =~ /No configuration file/
		end
	end

	context "guardian config validate (file) -- '.yaml' format validation" do
		it "should display a warning if the project name is not set" do
			write_settings(nil, nil, nil, config)

			@options.push('-f=test.yaml')
			output = capture(:stdout) { Guardian::CLI.start(@options) }

			FileUtils.rm_f([@config])
			output.should =~ /project name not set/
		end

		it "should display a success message with the project name if found" do
			project = {'project' => 'katana'}
			write_settings(project, nil, nil, @config)

			@options.push('-f=test.yaml')
			output = capture(:stdout) { Guardian::CLI.start(@options) }

			FileUtils.rm_f([@config])
			output.should =~ /project name 'katana' detected/
		end

		it "should display a warning no guards are specified" do
			write_settings(nil, nil, nil, @config)

			options.push('-f=test.yaml')
			output = capture(:stdout) { Guardian::CLI.start(@options) }
			FileUtils.rm_f([@config])
			output.should =~ /no guards specified/
		end

		it "should display a success message for each guard found" do
			guards = {'guards' => %w[bundler rspec]}
			write_settings(nil, guards, nil, config)

			@options.push('-f=test.yaml')
			output = capture(:stdout) { Guardian::CLI.start(@options) }
			FileUtils.rm_f([@config])
			output.should =~ /guard-bundler detected/
			output.should =~ /guard-rspec detected/
		end

		it "should display compound status messages" do
			project = {'project' => 'project_zero'}
			write_settings(project, nil, nil, @config)

			@options.push('-f=test.yaml')
			output = capture(:stdout) { Guardian::CLI.start(@options) }
			FileUtils.rm_f([@config])
			output.should =~ /project name 'project_zero' detected/
			output.should =~ /no guards specified/
		end

		it "should display a warning if no template is specified" do
			write_settings(nil, nil, nil, config)

			@options.push('-f=test')
			output = capture(:stdout) { Guardian::CLI.start(@options) }

			FileUtils.rm_r([config])
			output.should =~ /no project template type specified/
		end

		it "should display a success message if the 'custom' template is specified" do
			template = {'template' => 'custom'}
			write_settings(nil, nil, template, @config)

			@options.push('-f=test')
			output = capture(:stdout) { Guardian::CLI.start(@options) }

			FileUtils.rm_r([@config])
			output.should =~ /project template type 'custom' detected/
		end

		it "should display a success message if an unsupported template type is specified" do
			template = {'template' => 'merb'}
			write_settings(nil, nil, template, @config)

			@options.push('-f=test')
			output = capture(:stdout) { Guardian::CLI.start(@options) }

			FileUtils.rm_r([@config])
			output.should =~ /unsupported template type 'merb' detected/
		end

	end

end


