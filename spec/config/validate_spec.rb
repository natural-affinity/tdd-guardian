require_relative '../spec_helper'
require_relative '../../lib/guardian'

describe Guardian::Config do
	include GuardianSpecHelper

	attr_accessor :cli, :options, :config

	before(:all) do
		@config = File.join(Guardian::CONFIG_PATH, 'test.yaml')
	end

	before(:each) do
		@cli = Guardian::Config.new
		@options = %w[config validate -f=test]
	end

	context "guardian config validate (no file)" do
		it "should require a --file option" do
			@options.delete_at(2)
			output = capture(:stderr) { Guardian::CLI.start(@options) }
			output.should =~ /No value provided for required options '--file'/
		end

		it "should allow a -f alias for --file" do
			@options[2] = '-f'
			output = capture(:stderr) { Guardian::CLI.start(@options) }
			output.should =~ /No value provided for required options '--file'/
		end

		it "should display a warning if the filename is empty" do
			@options[2] = '--file='
			output = capture(:stdout) { Guardian::CLI.start(@options) }
			output.include?("No configuration file named '' found").should == true
		end

		it "should display a warning and not allow paths in the filename" do
			@options[2] = '--file=/blah'
			output = capture(:stdout) { Guardian::CLI.start(@options) }
			output.include?("No configuration file named '/blah.yaml' found").should == true
		end

		it "should invoke guardian <config> <list> if no files found" do
			@options[2] = '--file='

			output = create_capture_remove(:stdout, @options, @config, nil)
			output.include?("test.yaml").should == true
		end
	end

	context "guardian config validate (file) -- invalid .yaml values" do
		it "should display a warning if the project name is not set" do
			output = create_capture_remove(:stdout, @options, @config, nil)
			output.should =~ /project name not specified/
		end

		it "should display a warning no guards are specified" do
			output = create_capture_remove(:stdout, @options, @config, nil)
			output.should =~ /no guards specified/
		end

		it "should display a warning if no template is specified" do
			output = create_capture_remove(:stdout, @options, @config, nil)
			output.should =~ /project template type not specified/
		end

		it "should display a warning if an unsupported template type is specified" do
			settings = {:template => {'template' => 'merb'}}
			output = create_capture_remove(:stdout, @options, @config, settings)
			output.should =~ /project template type 'merb' is unsupported/
		end

		it "should display a warning if a project installation root is not specified" do
			output = create_capture_remove(:stdout, @options, @config, nil)
			output.should =~ /project installation directory does not exist/
		end

		it "should display compound status messages" do
			settings = {:project => {'project' => 'project_zero'}}
			output = create_capture_remove(:stdout, @options, @config, settings)
			output.should =~ /project name 'project_zero' detected/
			output.should =~ /no guards specified/
			output.should =~ /project template type not specified/
		end

		it "should display a warning for each guard for which no patterns(watch and block) are specified" do
			settings = {:guards => {'guards' => %w[bundler rspec]}, :single_guards => [{'rspec' => nil}]}

			output = create_capture_remove(:stdout, @options, @config, settings)
			output.should =~ /guard\-bundler has no watch and block pattern\(s\) specified/
			output.should =~ /guard\-rspec has no watch and block pattern\(s\) specified/
		end

		it "should display a warning for each guard for which a partial(watch or block) pattern is specified" do
			single_guards = [{'rspec' => {'patterns' => [{'watch' => 'spec'}]}},
											 {'bundler' => {'patterns' => [{'block' => 'spec'}]}}]
			settings = {:guards => {'guards' => %w[bundler rspec]}, :single_guards => single_guards}
			output = create_capture_remove(:stdout, @options, @config, settings)
			output.should =~ /guard\-rspec has an invalid pattern: watch='spec' block=''/
			output.should =~ /guard\-bundler has an invalid pattern: watch='' block='spec'/
		end
	end

	context "guardian config validate (file) -- valid .yaml values" do
			it "should display a success message with the project name if found" do
			settings = {:project => {'project' => 'katana'}}
			output = create_capture_remove(:stdout, @options, @config, settings)
			output.should =~ /project name 'katana' detected/
		end

		it "should display a success message if the 'general' template is specified" do
			settings = {:template => {'template' => 'general'}}
			output = create_capture_remove(:stdout, @options, @config, settings)
			output.should =~ /project template type 'general' detected/
		end

		it "should display a success message with the path if a root is specified" do
			settings = {:root => {'root' => '~/workspace'}}
			output = create_capture_remove(:stdout, @options, @config, settings)
			output.should =~ /project installation root \/Users\/zerocool\/workspace detected/
		end

		it "should display a success message for each guard found" do
			settings = {:guards => {'guards' => %w[bundler rspec]}}
			output = create_capture_remove(:stdout, @options, @config, settings)
			output.should =~ /guard-bundler detected/
			output.should =~ /guard-rspec detected/
		end

		it "should display a single success message for guard if all of its patterns are valid" do
			single_guards = [{'rspec' => {'patterns' => [{'watch' => 'watch a', 'block' => 'block a'},
																									 {'watch' => 'watch b', 'block' => 'block b'}]}},
											 {'bundler' => {'patterns' => [{'watch' => 'watch c', 'block' => 'block c'}]}}]

			settings = {:guards => {'guards' => %w[bundler rspec]}, :single_guards => single_guards}
			output = create_capture_remove(:stdout, @options, @config, settings)
			output.include?("guard-rspec has valid patterns")
			output.include?("guard\-bundler has valid patterns")
		end

	end

end
