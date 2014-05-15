# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestRegrServer < Test::Unit::TestCase
  include Client

  # regression test for https://github.com/evilsocket/gibson/commit/3eb380115af6432872f5f4ba3c1091157569b56b
  #
  # NOTE:
  # Make sure to run the test server with '--expired_cron 1'
  def test_server_regression_item_count
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
end








