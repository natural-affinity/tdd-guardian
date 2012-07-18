require 'simplecov'

SimpleCov.start
	
require_relative '../lib/configuration_reader'

describe ConfigurationReader do
	
	before(:each) do
  	@reader = ConfigurationReader.new
	end

	it "should load settings from a default file: config/settings.yaml" do
  	@reader.load.should == true
  end

end
