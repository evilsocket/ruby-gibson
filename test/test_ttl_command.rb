# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestTTLCommand < Test::Unit::TestCase
  include Client

  def test_ttl
    assert_equal 'bar', @gibson.set( 0, 'test#foo', 'bar' )
    assert_equal true, @gibson.ttl( 'test#foo', 1 )

    sleep 1

    assert_raise Gibson::NotFoundError do
      @gibson.get( 'test#foo' )
    end
  end
end








