require 'rubygems'
require 'webmock'

require File.dirname(__FILE__) + '/spec_helper'

$: << File.dirname(__FILE__) + '/../lib'
require 'logworm.rb'

describe Logworm::Config, " initialization" do
  
  before do
    %x[rm .logworm]
    %x[mv .gitignore .gitignore_old]
  end
  
  after do
    %x[mv .gitignore_old .gitignore]
  end

  it "should create a new .logworm file on save" do
    url = "xxx"
    File.should_not exist(".logworm")
    Logworm::Config.instance.save(url)
    File.should exist(".logworm")
    Logworm::Config.instance.read.should be_file_found
    Logworm::Config.instance.url.should == url
  end

  it "should add .logworm to .gitignore" do
    File.should_not exist(".gitignore")
    Logworm::Config.instance.save("xxx")
    File.should exist(".gitignore")
    File.open('.gitignore').readline.strip.should == ".logworm"
  end

end
