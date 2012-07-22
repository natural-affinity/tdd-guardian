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
		@options = %w[config validate -f=test]
	end

	context "guardian config validate (no file)" do
		it "should require a --file option" do
			@options.delete_at(2)
			output = capture(:stderr) { Guardian::CLI.start(@options) }
			output.should =~ /No value provided for required options '--file'/
		end

		it "should allow a -f alias for --file" do
			@options[2] = '-f'
			output = capture(:stderr) { Guardian::CLI.start(@options) }
			output.should =~ /No value provided for required options '--file'/
		end

		it "should display a warning if the filename is empty" do
			@options[2] = '--file='
			output = capture(:stdout) { Guardian::CLI.start(@options) }
			output.include?("No configuration file named '' found").should == true
		end

		it "should display a warning and not allow paths in the filename" do
			@options[2] = '--file=/blah'
			output = capture(:stdout) { Guardian::CLI.start(@options) }
			output.include?("No configuration file named '/blah.yaml' found").should == true
		end

		it "should invoke guardian <config> <list> if no files found" do
			@options[2] = '--file='

			output = create_capture_remove(:stdout, @options, @config, nil)
			output.include?("test.yaml").should == true
		end
	end

	context "guardian config validate (file)" do
		it "should auto add the yaml extension to the specified config file name" do
			@options[2] = '-f=test'
			output = create_capture_remove(:stdout, @options, @config, nil)
			output.should_not =~ /No configuration file/
		end
	end

	context "guardian config validate (file) -- invalid .yaml values" do
		it "should display a warning if the project name is not set" do
			output = create_capture_remove(:stdout, @options, @config, nil)
			output.should =~ /project name not set/
		end

		it "should display a warning no guards are specified" do
			output = create_capture_remove(:stdout, @options, @config, nil)
			output.should =~ /no guards specified/
		end

		it "should display a warning if no template is specified" do
			output = create_capture_remove(:stdout, @options, @config, nil)
			output.should =~ /no project template type specified/
		end

		it "should display a warning if an unsupported template type is specified" do
			settings = {:template => {'template' => 'merb'}}
			output = create_capture_remove(:stdout, @options, @config, settings)
			output.should =~ /unsupported template type 'merb' detected/
		end

		it "should display compound status messages" do
			settings = {:project => {'project' => 'project_zero'}}
			output = create_capture_remove(:stdout, @options, @config, settings)
			output.should =~ /project name 'project_zero' detected/
			output.should =~ /no guards specified/
			output.should =~ /no project template type specified/
		end
	end

	context "guardian config validate (file) -- valid .yaml values" do
			it "should display a success message with the project name if found" do
			settings = {:project => {'project' => 'katana'}}
			output = create_capture_remove(:stdout, @options, @config, settings)
			output.should =~ /project name 'katana' detected/
		end

		it "should display a success message for each guard found" do
			settings = {:guards => {'guards' => %w[bundler rspec]}}
			output = create_capture_remove(:stdout, @options, @config, settings)
			output.should =~ /guard-bundler detected/
			output.should =~ /guard-rspec detected/
		end

		it "should display a success message if the 'custom' template is specified" do
			settings = {:template => {'template' => 'custom'}}
			output = create_capture_remove(:stdout, @options, @config, settings)
			output.should =~ /project template type 'custom' detected/
		end
	end

end
