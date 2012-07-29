require_relative '../spec_helper'
require_relative '../../lib/guardian'

describe Guardian::Config do
	include GuardianSpecHelper

	before(:all) do
		@directory = get_test_path(Guardian::TEMP_PATH)
		@fixture = File.join(Guardian::ROOT, 'spec/assets/Guardfile.fixture')
		@command = 'guardfile'
		@klass = Guardian::Generate
	end

	before(:each) do
		@options = {:file => 'test.yaml', :init => true}
		create_valid_config(File.join(Guardian::CONFIG_PATH, 'test.yaml'))
	end

	after(:each) do
		FileUtils.rm_f([File.join(Guardian::CONFIG_PATH, 'test.yaml')])
		FileUtils.rm_f([File.join(Guardian::CONFIG_PATH, '.test.yaml.dir')])
		delete_folder(@directory)
	end

	context "with guard init" do
		it "should run the gemfile task if no Gemfile exists" do
			run_cli(@klass, @options, @command)
			File.file?(File.join(@directory, 'Gemfile')).should == true
		end

		it "should not run guard init for any guard without --init" do
			@options[:init] = false
			run_cli(@klass, @options, @command, true).length == 0
		end

		it "should run guard init for each guard if invoked with --init" do
			ret = run_cli(@klass, @options, @command, true)
			ret.length.should == 4
			(ret - [true, true, true, true]).length.should == 0
		end
	end

	it "should create the Guardfile if it does not exist" do
		run_cli(@klass, @options, @command)
		FileUtils.compare_file(File.join(@directory, 'Guardfile'), @fixture).should == true
	end
end