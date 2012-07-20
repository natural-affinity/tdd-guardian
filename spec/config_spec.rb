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
		end

	end

end
