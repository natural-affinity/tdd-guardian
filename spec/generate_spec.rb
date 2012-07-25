require 'spec_helper'
require_relative '../lib/guardian'

describe Guardian::Generate do
	include GuardianSpecHelper

	before(:each) do
		@options = %w[generate]
	end

	let(:output) { capture(:stdout) {Guardian::CLI.start(@options)} }

	it "should have the following subcommands" do
		output.should =~ /guardian generate all/
		output.should =~ /guardian generate project/
		output.should =~ /guardian generate gemfile/
		output.should =~ /guardian generate guardfile/
	end

	it "should feature a --file=config (alias -f) class option" do
		output.include?("-f, [--file=").should == true
	end

	it "should feature a --clean (alias -c) class option" do
		output.include?("-c, [--clean").should == true
	end
end
