# frozen_string_literal: true

require "test_helper"

class TestDatacenterDetector < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::DatacenterDetector::VERSION
  end

  def test_loopback_dont_break_it
    ddc_query = DatacenterDetector::Client.new.query(ip: '127.0.0.1')
  end

  def test_it_parses_result
    hash = { cidr: "3.5.140.0/22",
             name: "Amazon AWS",
             is_datacenter: true,
             retreived_at: "CURRENT_TIMESTAMP",
             created_at: "2022-08-01 03:55:00",
             result: { ip: "3.5.140.2",
                       is_datacenter: true,
                       src: "selfPublished",
                       cidr: "3.5.140.0/22",
                       region: "ap-northeast-2",
                       datacenter: "Amazon AWS",
                       service: "AMAZON",
                       network_border_group: "ap-northeast-2",
                       rir: "arin",
                       asn: { asn: 16_509, cidr: "3.5.140.0/22", descr: "AMAZON-02, US", country: "us",
                              active: true },
                       location: { country: "us" },
                       elapsed_ms: 0.21 } }

    to_ostruct = DatacenterDetector.to_ostruct(hash)

    to_hash = DatacenterDetector.to_hash(to_ostruct)

    assert_equal hash, to_hash
  end

  def test_unhashing
    skip
    str = "{\"cidr\":\"3.5.140.0/22\",\"name\":\"Amazon AWS\",\"is_datacenter\":true,\"retreived_at\":\"CURRENT_TIMESTAMP\",\"created_at\":\"2022-08-01 03:55:00\",\"result\":\"#<OpenStruct ip=\\\"3.5.140.2\\\", is_datacenter=true, src=\\\"selfPublished\\\", cidr=\\\"3.5.140.0/22\\\", region=\\\"ap-northeast-2\\\", datacenter=\\\"Amazon AWS\\\", service=\\\"AMAZON\\\", network_border_group=\\\"ap-northeast-2\\\", rir=\\\"arin\\\", asn=\\\"#<OpenStruct asn=16509, cidr=\\\\\\\"3.5.140.0/22\\\\\\\", descr=\\\\\\\"AMAZON-02, US\\\\\\\", country=\\\\\\\"us\\\\\\\", active=true>\\\", location=\\\"#<OpenStruct country=\\\\\\\"us\\\\\\\">\\\", elapsed_ms=0.21>\"}"

    DatacenterDetector.to_hash(JSON.parse(str))
  end
end
