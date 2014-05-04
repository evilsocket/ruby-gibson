# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestKeysCommand < Test::Unit::TestCase
  include Client

  def test_keys
    assert_equal @gibson.set( 0, 'test#aaa', 'bar' ), 'bar'
    assert_equal @gibson.set( 0, 'test#aab', 'bar' ), 'bar'
    assert_equal @gibson.set( 0, 'test#aac', 'bar' ), 'bar'

    keys = @gibson.keys 'test#a'
    assert_equal [ 'test#aaa', 'test#aab', 'test#aac' ], keys.values

    assert_equal true, @gibson.del('test#aab')
  
    keys = @gibson.keys 'test#a'
    assert_equal [ 'test#aaa', 'test#aac' ], keys.values
    
    assert_equal true, @gibson.del('test#aaa')
    
    keys = @gibson.keys 'test#a'
    assert_equal [ 'test#aac' ], keys.values
    
    assert_equal true, @gibson.del('test#aac')
    
    assert_raise Gibson::NotFoundError do
      @gibson.keys 'test#a'
    end
  end
end





