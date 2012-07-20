require 'spec_helper'
require_relative '../lib/guardian'

describe Guardian::CLI do
	include GuardianSpecHelper

	attr_accessor :cli

	before(:each) do
		@cli = Guardian::CLI.new
	end

	it "should feature the following commands" do
		output = capture(:stdout) { Guardian::CLI.start }
		output.should =~ /guardian help/
		output.should =~ /guardian --version/
		output.should =~ /guardian config/
	end

	it "should display version details with <guardian> --version" do
		options = %w[--version]
		output = capture(:stdout) { Guardian::CLI.start(options) }
		output.should =~ /Guardian version 0\.1\.0 \nCopyright \(C\) 2012 Rizwan Tejpar \n/
	end

	it "should display version details with <guardian> version" do
		output = capture(:stdout) { @cli.version }
		output.should =~ /Guardian version 0\.1\.0 \nCopyright \(C\) 2012 Rizwan Tejpar \n/
	end

end
