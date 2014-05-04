# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestIncCommand < Test::Unit::TestCase
  include Client

  def test_inc
    assert_equal @gibson.set( 0, 'test#foo', '1' ), '1'

    assert_equal @gibson.inc('test#foo'), 2
    assert_equal @gibson.get('test#foo'), 2
  end

  def test_nan
    assert_equal @gibson.set( 0, 'test#nan', 'nan' ), 'nan'

    assert_raise Gibson::NaNError do
      @gibson.inc 'test#nan'
    end

    assert_equal @gibson.get('test#nan'), 'nan'
  end
end




