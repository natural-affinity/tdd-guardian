require 'simplecov'

SimpleCov.start
	
require_relative '../lib/configuration_reader'

describe ConfigurationReader do
	CONFIG_FILE = 'config/settings.yaml'

	before(:each) do
  	@reader = ConfigurationReader.new
	end

	it "should load settings from a default file: config/settings.yaml" do
  	@reader.load.should == true
  end

	it "should load default settings on initialize" do
  	ConfigurationReader.new.yaml.should_not == nil
	end

	it "should load a list of guards" do

  	# Seed settings.yaml with guards
  	guards = {'guards' => ['bundler', 'shell', 'rspec']}
    File.open(CONFIG_FILE, 'w') {|f| f.write(guards.to_yaml) }

		# Re-load and parse YAML
		@reader.load.should == true
		@reader.parse
		@reader.guards.each do | guard | 
    	guards['guards'].include?(guard).should == true
		end

	end
end
