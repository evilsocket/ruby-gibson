# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestDecCommand < Test::Unit::TestCase
  include Client

  def test_dec
    assert_equal @gibson.set( 0, 'test#foo', '1' ), '1'
    
    (0..-50).each do |step|
      assert_equal @gibson.dec 'test#foo', step
      assert_equal @gibson.get 'test#foo', step
    end
  end

  def test_nan
    assert_equal @gibson.set( 0, 'test#nan', 'nan' ), 'nan'

    assert_raise Gibson::NaNError do
      @gibson.dec 'test#nan'
    end

    assert_equal @gibson.get('test#nan'), 'nan'
  end
end

