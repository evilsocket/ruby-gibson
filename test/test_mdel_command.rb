# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestMDelCommand < Test::Unit::TestCase
  include Client

  def test_mdel
    data = {
      'test#aaa' => 'a',
      'test#aab' => 'b',
      'test#aac' => 'c'
    }

    data.each do |key,value|
      assert_equal @gibson.set( 0, key, value ), value
    end

    assert_equal 3, @gibson.mdel('test#a')

    data.each do |key,value|
      assert_raise Gibson::NotFoundError do
        @gibson.get(key)
      end
    end

    assert_raise Gibson::NotFoundError do
      @gibson.mdel('test#a')
    end
  end

  def test_mdel_big_buffer
    big = 'a' * 50000

    (0..499).each do |step|
      ret = @gibson.set( 0, "test#big#{step}", big )
      assert_equal big.length, ret.length
      assert_equal big, ret
    end

    assert_equal 500, @gibson.mdel('test#big')
  end
end



