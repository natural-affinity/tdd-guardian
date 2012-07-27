require_relative '../spec_helper'
require_relative '../../lib/guardian'

describe Guardian::Generate do
	include GuardianSpecHelper

	before(:all) do
		@directory = '/Users/zerocool/workspace/test'
		@gemfix = File.join(Guardian::ROOT, 'spec/assets/Gemfile.fixture')
		@guardfix = File.join(Guardian::ROOT, 'spec/assets/Guardfile.fixture')
		@command = 'all'
		@klass = Guardian::Generate
		@options = {:file => 'test', :init => true}
	end

	before(:each) do
		create_valid_config(File.join(Guardian::CONFIG_PATH, 'test.yaml'))
	end

	after(:each) do
		FileUtils.rm_f([File.join(Guardian::CONFIG_PATH, 'test.yaml')])
		FileUtils.rm_f([File.join(Guardian::CONFIG_PATH, '.test.yaml.dir')])
		delete_folder(@directory)
	end

	context "general template" do
		it "should create the Gemfile, Guardfile, and directory structure" do
			run_cli(@klass, @options, @command)

			FileUtils.compare_file(File.join(@directory, 'Gemfile'), @gemfix).should == true
			FileUtils.compare_file(File.join(@directory, 'Guardfile'), @guardfix).should == true
			File.directory?(File.join(@directory, 'bin')).should == true
			File.directory?(File.join(@directory, 'lib')).should == true
			File.directory?(File.join(@directory, 'scripts')).should == true
		end
	end
end