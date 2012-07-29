require_relative '../spec_helper'
require_relative '../../lib/guardian'

describe Guardian::Config do
	include GuardianSpecHelper

	attr_accessor :cli

	before(:each) do
		@options = %w[config list]
		@cli = Guardian::Config.new
	end

	context "guardian config list" do
		it "should not list the settings.yaml internal config file" do
			output = capture(:stdout) { @cli.list }
			output.should_not =~ /settings\.yaml/
		end

		it "should not list any hidden files" do
			hidden_file = File.join(Guardian::CONFIG_PATH, '.dotfile_test')
			output = create_capture_remove(:stdout, @options, hidden_file, nil)
			output.should_not =~ /\.dotfile_test/
		end

		it "should only list files that end with .yaml" do
			yaml = File.join(Guardian::CONFIG_PATH, 'test_project.yaml')
			example = File.join(Guardian::CONFIG_PATH, 'test_example.yaml.example')
			invalid = File.join(Guardian::CONFIG_PATH, 'test_invalid.yml')

			FileUtils.touch([yaml, example, invalid])
			output = capture(:stdout) { @cli.list }
			FileUtils.rm([yaml, example, invalid])

			output.should =~ /test_project\.yaml/
			output.should_not =~ /test_example\.yaml\.example/
			output.should_not =~ /test_invalid\.yml/
		end

		it "should display a warning if no configuration files are found" do
			output = capture(:stdout) { @cli.list }
			output.include?("No configuration files found.").should == true
			output.include?("guardian <config> <generate>").should == true
		end
	end

end

