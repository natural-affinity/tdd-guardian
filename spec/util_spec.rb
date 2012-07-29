require 'spec_helper'
require_relative '../lib/guardian'

describe Guardian::Util do
	include GuardianSpecHelper

	before(:each) do
		@util = Guardian::Util.new
	end

	context "create a target path" do
		it "should produce a link target file named as follows" do
			@util.target('test.yaml').should == '.test.yaml.dir'
		end

		it "should produce a link target path as follows" do
			@util.target('test.yaml', true).should == './config/.test.yaml.dir'
		end

		it "should produce a link target file with subpath as follows" do
			@util.target('test.yaml', true, 'somefile').should == './config/.test.yaml.dir/somefile'
		end

		it "should produce an absolute link target path as follows" do
			@util.target('test.yaml', true, nil, false).should == File.join(Guardian::CONFIG_PATH, '.test.yaml.dir')
		end
	end

	context "run a command" do
		it "should run a command inside a directory, linked via config/<target>" do
			path = get_test_path(Guardian::TEMP_PATH)

			create_folder(path)
			FileUtils.ln_s(path, @util.target('test.yaml', true))

			@util.exec('echo "blah" > out.txt', 'test.yaml').should == true
			File.file?(File.join(path, 'out.txt')).should == true

			FileUtils.rm_f(@util.target('test.yaml', true))
			delete_folder(path)
		end

		it "should pass a conditional to block command execution" do
			@util.exec('echo "blah" > out.txt', '_', false).should == false
		end

		it "should invoke an existing thor class and task w/options" do
			@gen = @util.invoke(Guardian::Generate, {:file => 'invalid.yaml'}, 'gemfile')
			@gen.is_a?(Guardian::Generate).should == true
			@gen.reader.is_a?(Guardian::Reader).should == true
		end
	end

	context "display status" do
		it "should display the specified error message if set" do
			output = capture(:stdout) {@util.display_status('some value', nil, "project name not specified") }
			output.should_not =~ /some value/
			output.should =~ /project name not specified/
		end

		it "should append the word 'detected' if a property is not an error" do
			output = capture(:stdout) {@util.display_status('project name', 'test-project', nil) }
			output.should =~ /project name 'test-project' detected/
		end

		it "should display multiple status lines for an array of valid values" do
			values = %w[bundler rspec]
			output = capture(:stdout) {@util.display_status('guard', values, nil) }
			output.should =~/guard\-bundler detected/
			output.should =~/guard\-rspec detected/
		end

		it "should allow the toggle of single quotes around 'valid values'" do
			output = capture(:stdout) {@util.display_status('guard-bundler', 'valid patterns', nil, false) }
			output.should_not =~ /'valid patterns'/

			output = capture(:stdout) {@util.display_status('guard-bundler', 'valid patterns', nil) }
			output.should =~ /'valid patterns'/
		end
	end
end
