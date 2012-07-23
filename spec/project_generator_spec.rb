require 'spec_helper'
require_relative '../lib/project_generator'

describe ProjectGenerator do
	include GuardianSpecHelper

	before(:each) do		
		@generator = ProjectGenerator.new
		@project = @generator.read_project_config.project
  	
  	delete_folder(@project)
	end

	it "should invoke the config reader to load settings" do	
		@generator.read_project_config.is_a?(Reader).should == true
	end

	it "should create an empty project directory if does not exist" do
		output = capture(:stdout){@generator.create_project_dir}
		output.should =~ /create/

		output = capture(:stdout){@generator.create_project_dir}
		output.should =~ /exist/
	end

	it "should remove existing project directory on create with --clean" do
		@generator.create_project_dir
		
		options = ['--clean']
		output = capture(:stdout){ProjectGenerator.start(options)}
		output.include?('remove').should == true
		output.include?('create').should == true
	end

	it "should create the project directory in dir with --target" do
		options = ['--target=tmp']
		folder = File.join('tmp', @project)
		
		ProjectGenerator.start(options)
		File.exists?(folder).should == true
		delete_folder(folder)
	end

	it "should generate a gemfile based on guard config from template" do
  	File.delete('gemtest')
  	@generator.create_gemfile
	end
end
