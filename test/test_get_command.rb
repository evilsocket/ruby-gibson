# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestGetCommand < Test::Unit::TestCase
  include Client

  def test_get
    assert_equal @gibson.set( 0, 'test#foo', 'bar' ), 'bar'
    
    assert_equal @gibson.get('test#foo'), 'bar'

    assert_raise Gibson::NotFoundError do
      @gibson.get 'test#moo'
    end
  end
end



