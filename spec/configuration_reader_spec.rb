require 'spec_helper'
require_relative '../lib/configuration_reader'

describe ConfigurationReader do
	include GuardianSpecHelper

	DEFAULT_CONFIG = 'config/settings.yaml'

	before(:each) do
		@project = {'project' => 'conan-the-barbarian'}
  	@guards = {'guards' => ['bundler', 'rspec']}

		write_settings(@project, @guards, DEFAULT_CONFIG)
  	@reader = ConfigurationReader.new
	end

	it "should read a default file [#{DEFAULT_CONFIG}] on init" do
  	@reader.yaml.should_not == nil

  	File.delete(DEFAULT_CONFIG)
  	ConfigurationReader.new.yaml.should == nil
	end

	it "should parse all settings on init" do
		@reader.project.should_not == nil
		@reader.guards.should_not == nil		
	end

	it "should load a project name" do
  	config = {'project' => 'conan-the-barbarian'}
  	YAML.stub(:load_file).and_return(config)

  	@reader.project.should == config['project']
	end

	it "should utilize a default project name if not specified" do
		project = {'project' => nil}
		write_settings(project, @guards)
		ConfigurationReader.new.project.should == 'new-project'

		write_settings({}, @guards)
		ConfigurationReader.new.project.should == 'new-project'
	end

	it "should load a list of guards" do
  	config = {'guards' => ['bundler', 'rspec']}
  	YAML.stub(:load_file).and_return(config)		

		config['guards'].each do | guard | 
    	@reader.guards.include?(guard).should == true
		end
	end

	it "should utilize a default guard if not specified" do
  	guards = [{'guards' => nil}, {}]

  	guards.each do | g |
    	write_settings(@project, g)  		
  		@reader = ConfigurationReader.new
  		@reader.guards.size.should == 1
    	@reader.guards.include?('bundler').should == true
  	end
  end

end
