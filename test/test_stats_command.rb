# encoding: UTF-8

require File.expand_path("helper", File.dirname(__FILE__))

class TestStatsCommand < Test::Unit::TestCase
  include Client

  def test_stats
    keys = [
      'server_version',
      'server_build_datetime',
      'server_allocator',
      'server_arch',
      'server_started',
      'server_time',
      'first_item_seen',
      'last_item_seen',
      'total_items',
      'total_compressed_items',
      'total_clients',
      'total_cron_done',
      'total_connections',
      'total_requests',
      'memory_available',
      'memory_usable',
      'memory_used',
      'memory_peak',
      'memory_fragmentation',
      'item_size_avg',
      'compr_rate_avg',
      'reqs_per_client_avg'
    ]
    
    stats = @gibson.stats

    keys.each do |key|
      assert_equal true, stats.has_key?(key)
    end
  end
end







