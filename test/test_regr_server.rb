# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestRegrServer < Test::Unit::TestCase
  include Client

  # regression test for https://github.com/evilsocket/gibson/commit/3eb380115af6432872f5f4ba3c1091157569b56b
  #
  # NOTE:
  # Make sure to run the test server with '--expired_cron 1'
  def test_server_regression_item_count
    # just in case
    @gibson.mdel( 'count_somelong' )
    
    assert_equal 'bar', @gibson.set( 0, 'test#foo1', 'bar' )
    assert_equal 'bar', @gibson.set( 1, 'test#foo2', 'bar' )

    assert_equal 2, @gibson.stats['total_items']

    sleep 2

    assert_equal 1, @gibson.stats['total_items']

    assert_equal true, @gibson.del('test#foo1')

    assert_raise Gibson::NotFoundError do
      @gibson.del 'test#foo2'
    end

    assert_equal 0, @gibson.stats['total_items']
  end

  # every M* operator takes a huge amount of time when a lot of items
  # are stored due to allocation in tr_search function.
  def test_server_regression_multi_handlers_on_lot_of_items
    150000.times do |i|
      key = "count_somelong::keywith::#{i}::different::stuff::1nside"
      value = "a"

      assert_equal @gibson.set( 0, key, value ), value
    end

    assert_equal @gibson.count( "count" ), 150000
    assert_equal @gibson.munlock( "count" ), 150000
  end
end
