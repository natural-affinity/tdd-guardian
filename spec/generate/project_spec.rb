require_relative '../spec_helper'
require_relative '../../lib/guardian'

describe Guardian::Generate do
	include GuardianSpecHelper

	before(:all) do
		@directory = get_test_path(Guardian::TEMP_PATH)
		@command = 'project'
		@klass = Guardian::Generate
		@options = {:file => 'test'}
	end

	before(:each) do
		create_valid_config(File.join(Guardian::CONFIG_PATH, 'test.yaml'))
	end

	after(:each) do
		FileUtils.rm_f([File.join(Guardian::CONFIG_PATH, 'test.yaml')])
		FileUtils.rm_f([File.join(Guardian::CONFIG_PATH, '.test.yaml.dir')])
		delete_folder(@directory)
	end

	context "all templates" do
		it "should create a features directory if cucumber is a specified guard" do
			run_cli(@klass, @options, @command).reader.guards.include?("cucumber").should == true
			File.directory?(File.join(@directory, 'features/step_definitions')).should == true
			File.directory?(File.join(@directory, 'features/support')).should == true
			File.directory?(File.join(@directory, 'test')).should == false
		end

		it "should create a spec directory if rspec is a specified guard" do
			run_cli(@klass, @options, @command).reader.guards.include?("rspec").should == true
			File.directory?(File.join(@directory, 'spec')).should == true
			File.directory?(File.join(@directory, 'test')).should == false
		end

		it "should create a test directory if cucumber and rspec are not specified" do
			create_valid_config(File.join(Guardian::CONFIG_PATH, 'test.yaml'), true)
			guards = run_cli(@klass, @options, @command).reader.guards
			guards.include?("rspec").should == false
			guards.include?("cucumber").should == false
			File.directory?(File.join(@directory, 'test')).should == true
		end

		it "should create the project directory structure if it does not exist" do
			run_cli(@klass, @options, @command)
			File.directory?(File.join(@directory, 'bin')).should == true
			File.directory?(File.join(@directory, 'lib')).should == true
			File.directory?(File.join(@directory, 'scripts')).should == true
		end
	end
end