require_relative '../spec_helper'
require_relative '../../lib/guardian'

describe Guardian::Generate do
	include GuardianSpecHelper

	before(:all) do
		@directory = get_test_path(Guardian::TEMP_PATH)
		@fixture = File.join(Guardian::ROOT, 'spec/assets/Runner.fixture')
		@command = 'runner'
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

	it "should create the scripts directory if it does not exist" do
		run_cli(@klass, @options, @command)
		File.directory?(File.join(@directory, 'scripts')).should == true
	end

	it "should create a start.sh script in <project>/scripts to help launch guard and/or other deps (e.g. thin)" do
		run_cli(@klass, @options, @command)
		FileUtils.compare_file(File.join(@directory, 'scripts/start.sh'), @fixture).should == true
	end

	it "should give the start.sh script execute permissions" do
		run_cli(@klass, @options, @command)
		File.executable?(File.join(@directory, 'scripts/start.sh')).should == true
	end
end