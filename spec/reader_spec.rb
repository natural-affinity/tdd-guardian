require 'spec_helper'
require_relative '../lib/guardian'

describe Guardian::Reader do
	include GuardianSpecHelper

	before(:each) do
		@reader = Guardian::Reader.new
	end

	it "should only support .yaml and .yaml.example files by default" do
		@reader.supported.length.should == 2
		@reader.supported.include?(%w[.yaml .yaml.example])
	end




end
