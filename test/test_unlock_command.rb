# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestUnlockCommand < Test::Unit::TestCase
  include Client

  def test_unlock
    assert_equal 'bar', @gibson.set( 0, 'test#foo', 'bar' )
    assert_equal true, @gibson.lock( 'test#foo', 1 )

    assert_raise Gibson::LockedError do
      @gibson.set( 0, 'test#foo', 'new' )
    end

    assert_equal true, @gibson.unlock( 'test#foo' )

    assert_equal 'new', @gibson.set( 0, 'test#foo', 'new' )
    assert_equal 'new', @gibson.get( 'test#foo' )
  end
end









