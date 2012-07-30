require 'spec_helper'
require_relative '../lib/guardian'

describe Guardian::Config do
  include GuardianSpecHelper

  it "should have the following subcommands" do
    options = %w[config]
    output = capture(:stdout) { Guardian::CLI.start(options) }
    output.should =~ /guardian config list/
    output.should =~ /guardian config validate/
    output.should =~ /guardian config generate/
  end
end
