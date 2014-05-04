# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestPingCommand < Test::Unit::TestCase
  include Client

  def test_ping
    assert_equal true, @gibson.ping
  end
end







