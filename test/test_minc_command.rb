# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestMIncCommand < Test::Unit::TestCase
  include Client

  def test_minc
    data = {
      'test#foo' => '1',
      'test#fuu' => '1'
    }

    data.each do |key,value|
      assert_equal @gibson.set( 0, key, value ), value
    end

    assert_equal @gibson.minc('test#f'), data.size

    data.each do |key,value|
      assert_equal @gibson.get( key ), ( value.to_i + 1 )
    end
  end

  def test_minc_nan
    data = {
      'test#foo' => '1',
      'test#fuu' => '1',
      'test#fii' => 'aint a number'
    }

    data.each do |key,value|
      assert_equal @gibson.set( 0, key, value ), value
    end

    assert_equal @gibson.minc('test#f'), ( data.size - 1 )
  end
end


