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
    it "should only allow .yaml files from #{Guardian::CONFIG_PATH} to be loaded" do
      yaml = File.join(Guardian::CONFIG_PATH, 'test.yaml')
      example = File.join(Guardian::CONFIG_PATH, 'test.yaml.example')

      FileUtils.touch([yaml, example])
      list = Guardian::Reader.new.available
      FileUtils.rm_f([yaml, example])

      list.length.should == 1
      (list - %w[test.yaml]).length.should == 0
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
      single_guards = [{'rspec' => {'patterns' => [{'watch' => 'spec', 'block' => 'm'}]}},
                       {'livereload' => {'patterns' => nil}}]
      settings = {:guards => {'guards' => %w[bundler rspec livereload]}, :single_guards => single_guards}
      reader = write_read_remove(settings)
      reader.patterns['rspec'][0].should == {'watch' => 'spec', 'block' => 'm'}
      reader.patterns['livereload'].should == nil
    end

    it "should only return the pattern for each guard if a watch or watch and block is set" do
      single_guards = [{'rspec' => {'patterns' => [{'watch' => 'spec', 'block' => 'm'}]}},
                       {'bundler' => {'patterns' => [{'block' => 'spec'}]}}]
      settings = {:guards => {'guards' => %w[bundler rspec livereload]}, :single_guards => single_guards}
      reader = write_read_remove(settings)
      reader.patterns['bundler'].should == nil
      reader.patterns['rspec'][0].should == {'watch' => 'spec', 'block' => 'm'}
      reader.patterns['livereload'].should == nil

      reader.errors['livereload'].should == nil
    end

    it "should return nil for any value not set" do
      reader = write_read_remove({})
      reader.project.nil?.should == true
      reader.guards.nil?.should == true
      reader.template.nil?.should == true
      reader.root.nil?.should == true
      reader.patterns == nil
    end
  end

  context "Error handling upon parse" do
    it "should store an error for each parsing error encountered" do
      reader = write_read_remove({})
      reader.errors['project'].should_not == nil
      reader.errors['template'].should_not == nil
      reader.errors['root'].should_not == nil
      reader.errors['guards'].should_not == nil
    end

    it "should not store an error if no pattern was set for a guard" do
      reader = write_read_remove({})
      reader.errors['patterns'].should == nil
    end

    it "should feature a convenience method to check if there are any errors" do
      reader = write_read_remove({})
      reader.has_errors?.should == true

      create_valid_config(File.join(Guardian::CONFIG_PATH, 'test.yaml'))
      reader = Guardian::Reader.new('test')
      reader.has_errors?.should == false
      delete_folder(File.join(Guardian::CONFIG_PATH, 'test.yaml'))
    end
  end

end
