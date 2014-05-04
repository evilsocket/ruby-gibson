# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestMGetCommand < Test::Unit::TestCase
  include Client

  def test_mget
    data = {
      'test#foo' => 'bar',
      'test#fuu' => 'bur',
      'test#fii' => 'bir'	
    }

    data.each do |key,value|
      assert_equal @gibson.set( 0, key, value ), value
    end

    assert_equal data, @gibson.mget( 'test#f' ) 
  end

  def test_mget_expired
    data = {
      'test#foo' => 'bar',
      'test#fuu' => 'bur',
      'test#fii' => 'bir'	
    }

    data.each do |key,value|
      assert_equal @gibson.set( 1, key, value ), value
    end
    
    sleep 1 

    assert_raise Gibson::NotFoundError do
      @gibson.mget( 'test#f' )
    end
  end

  def test_mget_binary
    binary = ['deadbeef'].pack('H*')
    data = {
      "test##{binary}#foo" => 'bar',
      "test##{binary}#fuu" => 'bur',
      "test##{binary}#fii" => 'bir'	
    }
    
    data.each do |key,value|
      assert_equal @gibson.set( 1, key, value ), value
    end

    assert_equal data, @gibson.mget("test##{binary}#")
  end
end




