require 'spec_helper'
require_relative '../lib/guardian'

describe Guardian::Config do
	include GuardianSpecHelper

	attr_accessor :cli

	before(:each) do
		@cli = Guardian::Config.new
	end

	it "should have the following subcommands" do
  	options = %w[config]	
		output = capture(:stdout) { Guardian::CLI.start(options) }
    output.should =~ /guardian config list/
		output.should =~ /guardian config validate/
	end
end
