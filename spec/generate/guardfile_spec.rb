require_relative '../spec_helper'
require_relative '../../lib/guardian'

describe Guardian::Config do
	include GuardianSpecHelper

	before(:all) do
		@directory = '/Users/zerocool/workspace/test'
		@fixture = File.join(Guardian::ROOT, 'spec/asset/Guardfile.fixture')
		@command = 'guardfile'
		@klass = Guardian::Generate
		@options = {:file => 'test.yaml'}
	end

	before(:each) do
		create_valid_config(File.join(Guardian::CONFIG_PATH, 'test.yaml'))
	end

	after(:each) do
		FileUtils.rm_f([File.join(Guardian::CONFIG_PATH, 'test.yaml')])
		FileUtils.rm_f([File.join(Guardian::CONFIG_PATH, '.test.yaml.dir')])
		delete_folder(@directory)
	end

	it "should create the Guardfile if it does not exist" do
		run_cli(@klass, @options, @command)
		FileUtils.compare_file(File.join(@directory, 'Guardfile'), @fixture).should == true
	end
end