require 'spec_helper'
require_relative '../lib/guardian'

describe Guardian::CLI do
	include GuardianSpecHelper

	attr_accessor :cli, :version

	before(:all) do
		@version = %r{Guardian version 0\.1\.56 \nCopyright \(C\) 2012 Rizwan Tejpar \n}
	end

	before(:each) do
		@cli = Guardian::CLI.new
	end

	it "should feature the following commands" do
		output = capture(:stdout) { Guardian::CLI.start }
		output.should =~ /guardian help/
		output.should =~ /guardian --version/
		output.should =~ /guardian config/
		output.should =~ /guardian generate/
	end

	it "should display version details with <guardian> --version" do
		options = %w[--version]
		output = capture(:stdout) { Guardian::CLI.start(options) }
		output.should =~ @version
	end

	it "should display version details with <guardian> version" do
		output = capture(:stdout) { @cli.version }
		output.should =~ @version
	end
end
