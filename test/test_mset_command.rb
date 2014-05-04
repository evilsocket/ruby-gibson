# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestMSetCommand < Test::Unit::TestCase
  include Client

  def test_mset
    data = {
      'test#foo' => 'boo',
      'test#fuu' => 'rar'
    }

    data.each do |key,value|
      assert_equal @gibson.set( 0, key, value ), value
    end

    assert_equal @gibson.mset( 'test#f', 'new' ), data.size

    data.each do |key,value|
      assert_equal @gibson.get( key ), 'new'
    end
  end

  def test_mset_locked
    data = {
      'test#foo' => 'boo',
      'test#fuu' => 'rar'
    }

    data.each do |key,value|
      assert_equal @gibson.set( 0, key, value ), value
    end

    assert_equal true, @gibson.lock( 'test#foo', 10 )

    assert_equal @gibson.mset( 'test#f', 1 ), data.size - 1
  end
end




