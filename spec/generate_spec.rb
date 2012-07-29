require 'spec_helper'
require_relative '../lib/guardian'

describe Guardian::Generate do
	include GuardianSpecHelper

	before(:all) do
		@directory = get_test_path(Guardian::TEMP_PATH)
		puts @directory
		@options = %w[generate]
		@fopts = {:file => 'test'}
		@klass = Guardian::Generate
		@commands = %w[gemfile guardfile project runner]
	end

	before(:each) do
		create_valid_config(File.join(Guardian::CONFIG_PATH, 'test.yaml'))
	end

	after(:all) do
		delete_folder(@directory)
		FileUtils.rm_f([File.join(Guardian::CONFIG_PATH, 'test.yaml')])
		FileUtils.rm_f([File.join(Guardian::CONFIG_PATH, '.test.yaml.dir')])
	end

	let(:output) { capture(:stdout) {Guardian::CLI.start(@options)} }

	it "should have the following subcommands" do
		output.should =~ /guardian generate all/
		output.should =~ /guardian generate project/
		output.should =~ /guardian generate gemfile/
		output.should =~ /guardian generate guardfile/
		output.should =~ /guardian generate runner/
	end

	it "should feature a --file=config (alias -f) class option" do
		output.include?("-f, [--file=").should == true
	end

	context "each subcommand" do
		it "should invoke the Guardian::Config.validate task when called" do
			@commands.each do | c |
				run_cli(@klass, {:file => 'invalid'}, c).reader.is_a?(Guardian::Reader).should == true
			end
		end

		it "should create the project directory if it does not exist" do
			@commands.each do | c |
				delete_folder(@directory)
				File.directory?(File.join(@directory)).should == false
				run_cli(@klass, @fopts, c)
				File.directory?(File.join(@directory)).should == true
			end
		end

		it "should create a symlink to the project directory in #{Guardian::CONFIG_PATH}" do
			@commands.each do | c |
				FileUtils.rm_f([File.join(Guardian::CONFIG_PATH, '.test.yaml.dir')])
				run_cli(@klass, @fopts, c)
				File.exists?(File.join(Guardian::CONFIG_PATH, '.test.yaml.dir')).should == true
			end
		end
	end
end
