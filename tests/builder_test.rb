require 'rubygems'
require 'test/unit'
require '../lib/base/query_builder'

class BuilderTest < Test::Unit::TestCase
  
  def setup
  end
	
  def teardown
  end

  def test_empty
    assert_equal "{}", Logworm::QueryBuilder.new({}).to_json
  end

  def test_fields
    assert_equal '{"fields":["a","b"]}', Logworm::QueryBuilder.new(:fields => 'a, b').to_json
    assert_equal '{"fields":["a","b"]}', Logworm::QueryBuilder.new(:fields => '"a", "b"').to_json
    assert_equal '{"fields":["a","b"]}', Logworm::QueryBuilder.new(:fields => ["a", "b"]).to_json
  end
  
  def test_aggregate
    q = {:aggregate_function => "count"}
    assert_equal '{"aggregate":{"function":"count"}}', Logworm::QueryBuilder.new(q).to_json
    q = {:aggregate_function => "a", :aggregate_argument => "b"}
    assert_equal '{"aggregate":{"argument":"b","function":"a"}}', Logworm::QueryBuilder.new(q).to_json
    q = {:aggregate_function => "a", :aggregate_argument => "b", :aggregate_group => "a,b,c"}
    assert_equal '{"aggregate":{"argument":"b","group_by":["a","b","c"],"function":"a"}}', Logworm::QueryBuilder.new(q).to_json
    q = {:aggregate_function => "a", :aggregate_argument => "b", :aggregate_group => ["a","b","c"]}
    assert_equal '{"aggregate":{"argument":"b","group_by":["a","b","c"],"function":"a"}}', Logworm::QueryBuilder.new(q).to_json
  end

  def test_conditions
    assert_equal '{"conditions":{"a":10,"b":"c"}}', Logworm::QueryBuilder.new(:conditions => '"a":10,  "b":"c"').to_json
    assert_equal '{"conditions":{"a":10,"b":"c"}}', Logworm::QueryBuilder.new(:conditions => ['"a":10',  '"b":"c"']).to_json
  end

  def test_times
    assert_equal '{}', Logworm::QueryBuilder.new(:blah => "2009").to_json
    assert_equal '{"timeframe":{"start":"2009"}}', Logworm::QueryBuilder.new(:start => "2009").to_json
    assert_equal '{"timeframe":{"end":"2009"}}', Logworm::QueryBuilder.new(:end => "2009").to_json
    assert_equal '{"timeframe":{"start":"2009","end":"2010"}}', Logworm::QueryBuilder.new(:start => "2009", :end => "2010").to_json
    assert_equal '{"timeframe":{"start":"2009","end":"2010"}}', Logworm::QueryBuilder.new(:start => 2009, :end => 2010).to_json
  end
  
  def test_limit
    assert_equal '{"limit":10}', Logworm::QueryBuilder.new(:limit => 10).to_json
    assert_equal '{}', Logworm::QueryBuilder.new(:limit => 200).to_json
  end

end