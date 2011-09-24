require File.dirname(__FILE__) + '/../lib/key_db'
require 'test/unit'

class TestSelect < Test::Unit::TestCase

  def test_select_with_nil_value_in_condition
     db = KeyDB.new([{:key1=>1,:key2=>2}])

     assert_equal [{:key1=>1,:key2=>2}], db.select(:key1=>nil,:key2=>nil)
  end

  def test_select_with_single_condition
     db = KeyDB.new([{:key1=>1,:key2=>2},{:key1=>1,:key2=>3}])

     assert_equal [{:key1=>1,:key2=>2},{:key1=>1,:key2=>3}], db.select(:key1=>1)
  end

  def test_select_with_combine_condition
     db = KeyDB.new([{:key1=>1,:key2=>2},{:key1=>1,:key2=>3}])

     assert_equal [{:key1=>1,:key2=>3}], db.select(:key1=>1,:key2=>3)
  end

  def test_select_with_db_having_array_value
     db = KeyDB.new([{:key1=>[1,2],:key2=>3},{:key1=>2,:key2=>4}])

     assert_equal [{:key1=>[1,2],:key2=>3},{:key1=>2,:key2=>4}], db.select(:key1=>2)
  end

  def test_select_with_block
     db = KeyDB.new([{:key1=>1,:key2=>2},{:key1=>1,:key2=>3}])

     assert_equal [0,1], db.select(:key1=>1) {|e| e[:key2] % 2 }
  end

end

