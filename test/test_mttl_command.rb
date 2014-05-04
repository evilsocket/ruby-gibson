# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestMTTLCommand < Test::Unit::TestCase
  include Client

  def test_mttl
    data = {
      'test#foo' => 'boo',
      'test#fuu' => 'rar',
      'test#fii' => 'mir'
    }

    data.each do |key,value|
      assert_equal @gibson.set( 0, key, value ), value
    end

    assert_equal @gibson.mttl( 'test#f', 1 ), data.size
    
    sleep 1
    
    data.each do |key,value|
      assert_raise Gibson::NotFoundError do
        @gibson.get( key )
      end
    end
  end
end





