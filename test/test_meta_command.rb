# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestMetaCommand < Test::Unit::TestCase
  include Client

  def test_meta_size
    big_data = 'a' * 50000

    assert_equal 'bar', @gibson.set( 0, 'test#aaa', 'bar' )
    assert_equal '1', @gibson.set( 0, 'test#aab', '1' )

    ret = @gibson.set( 0, 'test#aac', big_data )
    assert_equal big_data.length, ret.length
    assert_equal big_data, ret

    assert_equal @gibson.meta('test#aaa', 'size'), 3
    assert_equal @gibson.meta('test#aab', 'size'), 1
    # big_data is compressed
    assert_equal true, @gibson.meta('test#aac', 'size') < big_data.size
  end

  def test_meta_access
    now = Time.now.to_i

    assert_equal 'bar', @gibson.set( 0, 'test#aaa', 'bar' )

    access = @gibson.meta( 'test#aaa', 'access' )
    assert_equal( true, ( access >= now - 1 && access <= now + 1 ) )
  end

  def test_meta_created
    now = Time.now.to_i

    assert_equal 'bar', @gibson.set( 0, 'test#aaa', 'bar' )

    created = @gibson.meta( 'test#aaa', 'created' )
    assert_equal( true, ( created >= now - 1 && created <= now + 1 ) )
  end

  def test_meta_ttl
    assert_equal 'bar', @gibson.set( 0, 'test#aaa', 'bar' )

    assert_equal( -1, @gibson.meta( 'test#aaa', 'ttl' ) )

    assert_equal true, @gibson.ttl( 'test#aaa', 10 )

    assert_equal 10, @gibson.meta( 'test#aaa', 'ttl' )
  end

  def test_meta_left
    assert_equal 'bar', @gibson.set( 0, 'test#aaa', 'bar' )

    assert_equal( -1, @gibson.meta( 'test#aaa', 'left' ) )
    
    assert_equal true, @gibson.ttl( 'test#aaa', 10 )
    
    assert_equal 10, @gibson.meta( 'test#aaa', 'left' )
    
    sleep 1

    assert_equal 9, @gibson.meta( 'test#aaa', 'left' )
  end

  def test_meta_lock
    assert_equal 'bar', @gibson.set( 0, 'test#aaa', 'bar' )

    assert_equal 0, @gibson.meta( 'test#aaa', 'lock' )

    assert_equal true, @gibson.lock( 'test#aaa', 10 )

    assert_equal 10, @gibson.meta( 'test#aaa', 'lock' )
  end

  def test_meta_encoding
    big_data = 'a' * 50000

    assert_equal 'bar', @gibson.set( 0, 'test#aaa', 'bar' )
    assert_equal '1', @gibson.set( 0, 'test#aab', '1' )

    ret = @gibson.set( 0, 'test#aac', big_data )
    assert_equal big_data.length, ret.length
    assert_equal big_data, ret

    assert_equal 2, @gibson.inc('test#aab')

    assert_equal Gibson::ENC_PLAIN,  @gibson.meta( 'test#aaa', 'encoding' )
    assert_equal Gibson::ENC_NUMBER, @gibson.meta( 'test#aab', 'encoding' )
    assert_equal Gibson::ENC_LZF,    @gibson.meta( 'test#aac', 'encoding' )
  end
end




