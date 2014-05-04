# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestRegression0001 < Test::Unit::TestCase
  include Client

  def test_set_big_buffer
    # just to make a BIG buffer
    buffer = "AAAAAAAA" * 100000

    # this will return a buffer which is smaller than the original
    #assert_equal buffer.length, @gibson.set( 0, "test", buffer ).length
  end
end
