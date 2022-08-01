# frozen_string_literal: true

require_relative "datacenter_detector/version"
require_relative "datacenter_detector/client"
require_relative "datacenter_detector/cache"
require "open-uri"
require "json"

module DatacenterDetector
  class Error < StandardError; end
  # Your code goes here...

  def self.query(ip)
    data = URI.open(url(ip))
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
    response
  end

  def self.url(ip)
    "https://api.incolumitas.com/datacenter?ip=#{ip}"
  end

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
