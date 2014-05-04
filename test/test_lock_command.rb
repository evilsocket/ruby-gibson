# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestLockCommand < Test::Unit::TestCase
  include Client

  def test_lock
    assert_equal @gibson.set( 0, 'test#foo', 'bar' ), 'bar'
    assert_equal true, @gibson.lock( 'test#foo', 1 )

    assert_raise Gibson::LockedError do
      @gibson.set( 0, 'test#foo', 'new' )
    end

    sleep 1

    assert_equal @gibson.set( 0, 'test#foo', 'new' ), 'new'
    assert_equal true, @gibson.del('test#foo')
  end

  def test_double_lock
    assert_equal @gibson.set( 0, 'test#foo', 'bar' ), 'bar'
    assert_equal true, @gibson.lock( 'test#foo', 10 )

    assert_raise Gibson::LockedError do
      @gibson.lock( 'test#foo', 10 )
    end

    assert_raise Gibson::LockedError do
      @gibson.del 'test#foo'
    end

    assert_equal true, @gibson.unlock('test#foo')
    assert_equal true, @gibson.del('test#foo')
  end
end






