# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestCountCommand < Test::Unit::TestCase
  include Client

  def test_count
    assert_equal @gibson.set( 0, 'test#aaa', 'bar' ), 'bar'
    assert_equal @gibson.set( 0, 'test#aab', 'bar' ), 'bar'
    assert_equal @gibson.set( 0, 'test#aac', 'bar' ), 'bar'
    
    assert_equal @gibson.count('test#a'), 3
  end
end
