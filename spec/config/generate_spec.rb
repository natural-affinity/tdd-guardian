require_relative '../spec_helper'
require_relative '../../lib/guardian'

describe Guardian::Config do
  include GuardianSpecHelper

  attr_accessor :cli

  before(:each) do
    @options = %w[config generate]
    @cli = Guardian::Config.new
  end

  it "should display a not implemented error message" do
    output = capture(:stdout) { @cli.generate }
    output.should =~ /Not Implemented Yet/
  end
end
