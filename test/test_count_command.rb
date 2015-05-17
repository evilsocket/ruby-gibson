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

  def test_count_many_items
    150000.times do |i|
      key = "count_somelong::keywith::#{i}::different::stuff::1nside"
      value = "a"

      assert_equal @gibson.set( 0, key, value ), value
    end

    assert_equal @gibson.count( "count" ), 150000
  end
end
