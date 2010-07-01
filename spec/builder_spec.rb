require 'rubygems'

require File.dirname(__FILE__) + '/spec_helper'

$: << File.dirname(__FILE__) + '/../lib'
require 'logworm.rb'

describe Logworm::QueryBuilder, " timeframes" do
  
  it " should accept Strings as time" do
    Logworm::QueryBuilder.new(:start => "2010-01-01").to_json.should == '{"timeframe":{"start":"2010-01-01"}}'
    Logworm::QueryBuilder.new(:end => "2010-01-01").to_json.should == '{"timeframe":{"end":"2010-01-01"}}'
  end
  
  it "should accept an Integer as time, to mean the year" do
    Logworm::QueryBuilder.new(:start => 2010).to_json.should == '{"timeframe":{"start":"2010"}}'
    Logworm::QueryBuilder.new(:end => 2010).to_json.should == '{"timeframe":{"end":"2010"}}'
  end

  it "should accept a Time object" do
    ts = Time.now
    Logworm::QueryBuilder.new(:start => ts).to_json.should == '{"timeframe":{"start":"' + ts.strftime("%Y-%m-%dT%H:%M:%SZ") + '"}}'
    Logworm::QueryBuilder.new(:end => ts).to_json.should   == '{"timeframe":{"end":"' + ts.strftime("%Y-%m-%dT%H:%M:%SZ") + '"}}'
  end

end
