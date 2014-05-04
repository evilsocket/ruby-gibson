# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestSetCommand < Test::Unit::TestCase
  include Client

  def test_set
    assert_equal 'bar', @gibson.set( 0, 'test#foo', 'bar' )
  end

  def test_set_with_ttl
    assert_equal 'bar', @gibson.set( 1, 'test#foo', 'bar' )

    sleep 1

    assert_raise Gibson::NotFoundError do
      @gibson.get('test#foo')
    end
  end

  def test_set_utf8
    values = [
        "This is the Euro symbol '€'.",
        "Télécom",
        "Weiß, Goldmann, Göbel, Weiss, Göthe, Goethe und Götz"	
    ]

    values.each do |value|
      assert_equal value, @gibson.set( 0, 'test#foo', value )
      assert_equal value, @gibson.get( 'test#foo' )
    end
  end

  def test_set_big_buffer
    big = 'a' * 1000000

    ret = @gibson.set( 0, 'test#foo', big )

    assert_equal big.length, ret.length
    assert_equal big, ret

    sleep 1
  end

  def test_set_binary_key
    binary = ['deadbeef'].pack('H*')

    (1..100).each do |step|
      key = "test##{binary}#foo"
      value = "bar#{step}"

      assert_equal value, @gibson.set( 0, key, value )
      assert_equal value, @gibson.get( key )
    end
  end

  def test_set_binary_value
    binary = ['deadbeef'].pack('H*')

    (1..100).each do |step|
      key = "test#foo#{step}"
      value = "bar#{binary}#{step}"

      assert_equal value, @gibson.set( 0, key, value )
      assert_equal value, @gibson.get( key )
    end
  end

  def test_set_binary_key_and_value
    binary = ['deadbeef'].pack('H*')

    (1..100).each do |step|
      key = "test##{binary}#foo#{step}"
      value = "bar#{binary}#{step}"

      assert_equal value, @gibson.set( 0, key, value )
      assert_equal value, @gibson.get( key )
    end
  end
end








