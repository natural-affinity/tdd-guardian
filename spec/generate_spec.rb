require 'spec_helper'
require_relative '../lib/guardian'

describe Guardian::Generate do
	include GuardianSpecHelper

	it "should have the following subcommands" do
		options = %w[generate]
		output = capture(:stdout) { Guardian::CLI.start(options) }
		output.should =~ /guardian generate all/
		output.should =~ /guardian generate project/
		output.should =~ /guardian generate gemfile/
		output.should =~ /guardian generate guardfile/
	end

end
