require 'spec_helper'
require_relative '../lib/guardian'

describe Guardian::Reader do
	include GuardianSpecHelper

	def write_read_remove(settings = nil, file = 'test.yaml')
		yaml = File.join(Guardian::CONFIG_PATH, file)

		unless settings.nil?
			write_settings(settings[:project],
										 settings[:guards],
										 settings[:template],
										 settings[:root],
										 settings[:single_guards],
										 yaml)

		else
			write_to_yaml(yaml, {'test' => 'data'})
		end

		reader = Guardian::Reader.new(file)
		FileUtils.rm_f([yaml])

		return reader
	end


	context "Fetch Available Configurations" do
		it "should only allow .yaml and .yaml.example files from #{Guardian::CONFIG_PATH} to be loaded" do
			yaml = File.join(Guardian::CONFIG_PATH, 'test.yaml')
			example = File.join(Guardian::CONFIG_PATH, 'test.yaml.example')

			FileUtils.touch([yaml, example])
			list = Guardian::Reader.new.available
			FileUtils.rm_f([yaml, example])

			list.length.should == 2
			(list - %w[test.yaml test.yaml.example]).length.should == 0
		end

		it "should not allow hidden files or settings.yaml to be loaded" do
			reader = write_read_remove(nil, '.dotfile.yaml')
			reader.available.length.should == 0
			File.exists?(File.join(Guardian::CONFIG_PATH, 'settings.yaml')).should == true
		end

		it "should automatically add the .yaml extension to supported files if not specified" do
			write_read_remove.file.should == 'test.yaml'
		end
	end

	context "Config File Parsing" do
		it "should return the project name if set" do
			settings = {:project => {'project' => 'zero'}}
			write_read_remove(settings).project.should == 'zero'
		end

		it "should return the project template type if supported" do
			settings = {:template => {'template' => 'general'}}
			reader = write_read_remove(settings)
			reader.template.should == 'general'

			settings[:template]['template'] = 'unsupported'
			reader = write_read_remove(settings)
			reader.template.should == nil
		end

		it "should return the project root if it is a valid directory" do
			settings = {:root => {'root' => '/bin'}}
			reader = write_read_remove(settings)
			reader.root.should == '/bin'

			settings[:root]['root'] = '/bin/sh'
			reader = write_read_remove(settings)
			reader.root.should == nil
		end

		it "should return the specified guards if set" do
			settings = {:guards => {'guards' => %w[bundler rspec livereload]}}
			reader = write_read_remove(settings)
			reader.guards.length.should == 3
			(reader.guards - %w[bundler livereload rspec]).length == 0
		end

		it "should return the patterns for each guard if set" do


		end

		it "should only return the pattern for each guard if a watch or watch and block is set" do

		end


		it "should return nil for any value not set" do
			reader = write_read_remove({})
			reader.project.nil?.should == true
			reader.guards.nil?.should == true
			reader.template.nil?.should == true
			reader.root.nil?.should == true
		end

	end

end
