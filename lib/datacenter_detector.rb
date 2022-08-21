# frozen_string_literal: true

require_relative "datacenter_detector/version"
require_relative "datacenter_detector/client"
require_relative "datacenter_detector/cache"
require "open-uri"
require "json"

module DatacenterDetector
  class ServerError < StandardError; end

  def self.query(ip)
    data = URI.open(url(ip), "User-Agent" => "DatacenterDetector/#{::DatacenterDetector::VERSION} (https://github.com/dkam/datacenter_detector)")
    body = data.read
    doc = JSON.parse(body)
    result = { status: data.status[0] }
    response = if doc.is_a?(Hash)
                 DatacenterDetector.to_ostruct(result.merge!({ result: doc }))
               else
                 DatacenterDetector.to_ostruct(result.merge!({ error: body }))
               end
    response.is_datacenter = response.result.is_datacenter
    response.name = response.result.server || response.result.datacenter || response.result.asn&.descr

    if ip == '127.0.0.1'
      response.result.cidr = '127.0.0.1/8'
      response.result.server = 'Loopback'
    end

    response
  rescue OpenURI::HTTPError => e
    raise DatacenterDetector::ServerError
  end

  def self.url(ip)
    "https://api.incolumitas.com/datacenter?ip=#{ip}"
  end

  # Recursively convert an object into an OpenStruct
  def self.to_ostruct(obj)
    obj = JSON.parse(obj) if obj.is_a?(String) && obj.valid_json?

    if obj.is_a?(Hash)
      OpenStruct.new(obj.map { |key, val| [key, to_ostruct(val)] }.to_h)
    elsif obj.is_a?(Array)
      obj.map { |o| to_ostruct(o) }
    else # Assumed to be a primitive value
      obj
    end
  end

  # Recursively convert an OpenStruct into a Hash
  def self.to_hash(obj)
    if obj.is_a?(OpenStruct)
      obj.to_h.transform_values { |v| DatacenterDetector.to_hash(v) }
    else
      obj
    end
  end
end

class String
  # https://gist.github.com/ascendbruce/7070951
  def valid_json?
    result = JSON.parse(self)
    result.is_a?(Hash) || result.is_a?(Array)
  rescue JSON::ParserError, TypeError
    false
  end
end
