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

	context "guardian config validate" do
  	it "should require a --file option" do
  		options = ["config", "validate"]
  		output = capture(:stderr) { Guardian::CLI.start(options) }
  	 	output.should =~ /No value provided for required options \'--file\'/ 
  	end

		it "should allow a -f alias for --file" do
			options = ['config', 'validate', '-f']
			output = capture(:stderr) { Guardian::CLI.start(options) }
  	 	output.should =~ /No value provided for required options \'--file\'/ 
		end

  	it "should display a warning if the filename is empty" do
    	options = ['config', 'validate', '--file=']
    	output = capture(:stdout) { Guardian::CLI.start(options) }
    	output.include?("No configuration file named '' found").should == true
  	end

		it "should display a warning and not allow paths in the filename" do
			options = ['config', 'validate', '--file=/blah']
			output = capture(:stdout) { Guardian::CLI.start(options) }
			output.include?("No configuration file named '/blah' found").should == true
		end

		it "should invoke guardian <config> <list> if no files found" do
    	config = File.join(Guardian::CONFIG_PATH, 'test.yaml')
      FileUtils.touch(config)

      options = ['config', 'validate', '--file=']
      output = capture(:stdout) { Guardian::CLI.start(options) }
			output.include?("test.yaml").should == true

			FileUtils.rm(config)
		end

	end

end
