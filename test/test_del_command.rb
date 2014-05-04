# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestDelCommand < Test::Unit::TestCase
  include Client

  def test_del
    assert_equal @gibson.set( 0, 'test#foo', 'bar' ), 'bar'
    
    assert_equal true, @gibson.del('test#foo')
    
    assert_raise Gibson::NotFoundError do
      @gibson.del 'test#foo'
    end

    assert_raise Gibson::NotFoundError do
      @gibson.get 'test#foo'
    end
  end
end


