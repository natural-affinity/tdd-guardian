require 'simplecov'

SimpleCov.start
	
require_relative '../lib/configuration_reader'

describe ConfigurationReader do
	DEFAULT_CONFIG = 'config/settings.yaml'

	before(:all) do
  	project = {'project' => 'conan-the-barbarian'}
  	guards = {'guards' => ['bundler', 'rspec']}
  	config = project.merge(guards)

  	File.open(DEFAULT_CONFIG, 'w') {|f| f.write(config.to_yaml) }
	end

	before(:each) do
  	@reader = ConfigurationReader.new
	end

	it "should load settings from a default file [config/settings.yaml]" do
  	@reader.load.should == true
  end

	it "should load default settings on initialize" do
  	ConfigurationReader.new.yaml.should_not == nil
	end

	it "should parse all settings on initialize" do
		reader = ConfigurationReader.new
		
		reader.project.should_not == nil
		reader.guards.should_not == nil		
	end

	it "should load a project name" do
  	config = {'project' => 'conan-the-barbarian'}
  	YAML.stub(:load_file).and_return(config)

  	@reader.project.should == config['project']
	end

	it "should load a list of guards" do
  	config = {'guards' => ['bundler', 'rspec']}
  	YAML.stub(:load_file).and_return(config)		

		config['guards'].each do | guard | 
    	@reader.guards.include?(guard).should == true
		end
	end

end
