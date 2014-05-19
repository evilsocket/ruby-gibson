# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

# This is a specific unit test for the new server object allocator
# pool.
class TestServerObjectPool < Test::Unit::TestCase
  include Client

  def test_if_stats_gives_correct_results
    keys = [
      'item_pool_current_used',
      'item_pool_current_capacity',
      'item_pool_total_capacity',
      'item_pool_object_size',
      'item_pool_max_block_size'
    ]
    
    stats = @gibson.stats

    keys.each do |key|
      assert_equal true, stats.has_key?(key)
    end 

    used  = stats['item_pool_current_used']
    space = stats['item_pool_current_capacity']
    total = stats['item_pool_total_capacity']

    assert_equal true, space > used

    # create new elements to make sure the total capacity is overflowed
    total.times do |i|
      assert_equal "foobar", @gibson.set( 0, "test#test_if_stats_gives_correct_results##{i}", "foobar" )
    end   

    # make sure the cron even does its job
    @gibson.ping

    stats = @gibson.stats

    keys.each do |key|
      assert_equal true, stats.has_key?(key)
    end 

    # the new capacity should be greater than the old one
    assert_equal true, total < stats['item_pool_total_capacity']
    # the current capacity should be the old one doubled
    assert_equal space * 2, stats['item_pool_current_capacity']
  end

  def test_if_items_are_reused
    # create a new item
    assert_equal 'foobar', @gibson.set( 0, "test#test_if_items_are_reused_a", "foobar" )

    stats = @gibson.stats
    used  = stats['item_pool_current_used']
      
    assert_equal true, @gibson.del( "test#test_if_items_are_reused_a" )

    stats = @gibson.stats
    assert_equal used, stats['item_pool_current_used']

    # make a new one
    assert_equal 'foobar', @gibson.set( 0, "test#test_if_items_are_reused_b", "foobar" )
    
    stats = @gibson.stats
    assert_equal used, stats['item_pool_current_used']
  end

end
