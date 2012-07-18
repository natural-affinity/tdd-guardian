require 'simplecov'

SimpleCov.start
	
require_relative '../lib/configuration_reader'

describe ConfigurationReader do

	before(:each) do
  	@reader = ConfigurationReader.new
	end

	it "should load settings from a default file [config/settings.yaml]" do
  	@reader.load.should == true
  end

	it "should load default settings on initialize" do
  	ConfigurationReader.new.yaml.should_not == nil
	end

	it "should load a list of guards" do
  	config = {'guards' => ['bundler', 'shell', 'rspec']}
  	YAML.stub(:load_file).and_return(config)		

		@reader.load.should == true
		@reader.parse
		@reader.guards.each do | guard | 
    	config['guards'].include?(guard).should == true
		end
	end

end
