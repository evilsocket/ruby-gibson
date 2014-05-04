# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestMUnlockCommand < Test::Unit::TestCase
  include Client

  def test_munlock
    data = {
      'test#foo' => 'boo',
      'test#fuu' => 'rar',
      'test#fii' => 'mir'
    }

    data.each do |key,value|
      assert_equal @gibson.set( 0, key, value ), value
    end

    assert_equal @gibson.mlock( 'test#f', 1 ), data.size

    data.each do |key,value|
      assert_raise Gibson::LockedError do
        @gibson.set( 0, key, 'new' )
      end
    end

    assert_equal @gibson.munlock( 'test#f', 1 ), data.size
    
    data.each do |key,value|
      assert_equal @gibson.set( 0, key, 'new' ), 'new'
    end
  end
end






