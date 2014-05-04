# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestMLockCommand < Test::Unit::TestCase
  include Client

  def test_mlock
    data = {
      'test#foo' => 'boo',
      'test#fuu' => 'rar'
    }

    data.each do |key,value|
      assert_equal @gibson.set( 0, key, value ), value
    end

    assert_equal @gibson.mlock('test#f',1), data.size

    data.each do |key,value|
      assert_raise Gibson::LockedError do
        @gibson.set( 0, key, 'new' )      
      end
    end

    sleep 1 

    data.each do |key,value|
      assert_equal @gibson.set( 0, key, 'new' ), 'new'
    end

  end

  def test_mlock_already_locked
    data = {
      'test#foo' => 'boo',
      'test#fuu' => 'rar'
    }

    data.each do |key,value|
      assert_equal @gibson.set( 0, key, value ), value
    end

    assert_equal true, @gibson.lock( 'test#foo', 10 )

    assert_equal @gibson.mlock('test#f',1), data.size - 1
  end
end



