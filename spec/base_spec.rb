require 'rubygems'
require 'webmock'

require File.dirname(__FILE__) + '/spec_helper'

$: << File.dirname(__FILE__) + '/../lib'
require 'logworm.rb'

describe Logworm::DB, " initialization" do
  before do
    File.delete(".logworm") if File.exist?(".logworm")
    Logworm::Config.instance.reset
  end
  
  it "should only accept proper URLs" do
    lambda {Logworm::DB.new('')}.should raise_exception(Logworm::ForbiddenAccessException)
    lambda {Logworm::DB.new('http://www.test.com')}.should   raise_exception(Logworm::ForbiddenAccessException)
    lambda {Logworm::DB.new('logworm://a:b@xxx/c/d')}.should raise_exception(Logworm::ForbiddenAccessException)
    lambda {Logworm::DB.new('logworm://a:b@/c/d/')}.should   raise_exception(Logworm::ForbiddenAccessException)
    lambda {Logworm::DB.new('logworm://a:b@sda//d/')}.should raise_exception(Logworm::ForbiddenAccessException)
    lambda {Logworm::DB.new('logworm://:b@sda//d/')}.should  raise_exception(Logworm::ForbiddenAccessException)
    lambda {Logworm::DB.new('logworm://a:b@xxx/c/d/')}.should_not raise_exception(Logworm::ForbiddenAccessException)
  end

  it "should be able to parse a proper logworm URL" do
    db = Logworm::DB.new('logworm://a:b@localhost:9401/c/d/')
    db.host.should == "localhost:9401"
    db.consumer_key.should == "a"
    db.consumer_secret.should == "b"
    db.token.should == "c"
    db.token_secret.should == "d"
  end

  it "should be able to read its configuration from a file" do
    File.open(".logworm", "w") do |f|
      f.puts 'logworm://a:b@localhost:9401/c/d/'
    end
    db = Logworm::DB.from_config
    db.host.should == "localhost:9401"
    db.consumer_key.should == "a"
    db.consumer_secret.should == "b"
    db.token.should == "c"
    db.token_secret.should == "d"
  end
  
  it "should fail if no logworm file (and no current Heroku application)" do
    db = Logworm::DB.from_config
    db.should == nil
  end
  
  # Note that this will fail unless it's run from the command line!
  it "should not be nil if we pass a proper app parameter" do
    db = Logworm::DB.from_config("lw-client")
    db.should_not == nil
    db.host.should == "db.logworm.com"
  end
  
  # Note that this will fail unless it's run from the command line!
  it "should not use a config file if app is passed" do 
    File.open(".logworm", "w") do |f|
      f.puts 'logworm://a:b@xxx:9401/c/d/'
    end
    db = Logworm::DB.from_config("lw-client")
    db.host.should == "db.logworm.com"  # The one from the app, not the config file
  end
  
  # Note that this will fail unless it's run from the command line!
  it "should not overwrite a config file if app is passed" do 
    File.open(".logworm", "w") do |f|
      f.puts 'logworm://a:b@xxx:9401/c/d/'
    end

    db = Logworm::DB.from_config("lw-client")
    Logworm::Config.instance.reset
    Logworm::Config.instance.read
    Logworm::Config.instance.url.should == 'logworm://a:b@xxx:9401/c/d/'
  end

end

describe Logworm::DB, " functioning" do
  
  host = "http://localhost:9401"
  
  before(:all) do
    @db = Logworm::DB.new('logworm://a:b@localhost:9401/c/d/')
  end
  
  it "should offer a call to get the list of tables --> /" do
    @db.should_receive(:db_call).with(:get, "#{host}/")
    @db.tables
  end
  
  it "should just parse and return the results of the call to get tables" do
    return_body =  [
            {"tablename" => "table1", "url" => "/table1", "last_write" => "2010-03-20 18:10:22", "rows" => 50},
            {"tablename" => "table2", "url" => "/table1", "last_write" => "2010-03-20 18:10:22", "rows" => 50}]
    stub_request(:get, "#{host}/").to_return(:body => return_body.to_json)
    @db.tables.should == return_body
  end
  
  it "should support a call to start a query --> POST /queries" do
    @db.should_receive(:db_call).with(:post, "#{host}/queries", {:table => "tbl1", :query => "a good query"})
    @db.query("tbl1", "a good query")
  end
  
  it "should just parse and return the results of the call to query" do
    return_body =  {"id" => 10, "query" => "q", "self_uri" => "/queries/10", "results_uri" => "/queries/10/results"}
    stub_request(:post, "#{host}/queries").with(:body => "query=q&table=table1").to_return(:body => return_body.to_json)
    @db.query("table1", "q").should == return_body
  end

  it "should support a call to retrieve the results of a query --> GET /queries/10/results" do
    @db.should_receive(:db_call).with(:get, "#{host}/queries/10/results")
    @db.results("#{host}/queries/10/results") rescue Exception # Returns an error when trying to parse results
  end
  
  it "should just parse and return the results of the call to retrieve results, but also add results field" do
    results     = [{"a" => 10, "b" => "2"}, {"a" => "x"}]
    return_body = {"id" => 10, "execution_time" => "5", 
                   "query_url" => "#{host}/queries/10", "results_url" => "#{host}/queries/10/results",
                   "results"   => results.to_json}
    stub_request(:get, "#{host}/queries/10/results").to_return(:body => return_body.to_json)
    @db.results("#{host}/queries/10/results").should == return_body.merge("results" => results)
  end
  
  it "should raise ForbiddenAccessException if 403" do
    stub_request(:get, "#{host}/").to_return(:status => 403)
    lambda {@db.tables}.should raise_exception(Logworm::ForbiddenAccessException)
  end

  it "should raise InvalidQueryException if query is not valid" do
    stub_request(:post, "#{host}/queries").to_return(:status => 400, :body => "Query error")
    lambda {@db.query("tbl1", "bad query")}.should raise_exception(Logworm::InvalidQueryException)
  end
  
  it "should raise DatabaseException if response from server is not JSON" do
    stub_request(:get, "#{host}/").to_return(:body => "blah")
    lambda {@db.tables}.should raise_exception(Logworm::DatabaseException)
  end
  

end
