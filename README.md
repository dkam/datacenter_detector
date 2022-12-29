# DatacenterDetector
The DatacenterDetector gem is no more. Below is a simple class to perform the same actions, but using a Redis cache via Kredis.

# A Working Cache

```ruby
require 'kredis'
require 'open-uri'

class IpAddressApi
  # Outside of Rails, configure Kredis like: 
  #   Kredis::Connections.connections[:shared] = Redis.new(url: "redis://localhost:6379/0")
  attr_accessor :prefix, :agent, :cache_only, :ttl

  def initialize(prefix: IpAddressApi.prefix, agent: IpAddressApi.agent, cache_only: false, ttl: 60 * 60 * 24)
    @cache_only = cache_only
    @prefix     = prefix
    @agent      = agent
    @ttl        = ttl 
  end
  
  def key_name(ip) = "#{@prefix}#{ip}"
  def hit_counter  = @hit_counter  ||= Kredis.counter("#{prefix}hits")
  def miss_counter = @miss_counter ||= Kredis.counter("#{prefix}miss")
  
  def stats
    hit  = hit_counter.value
    miss = miss_counter.value

    {hit: hit, miss:, total: hit + miss}
  end
  def self.stats = IpAddressApi.new.stats

  def reset_stats
    hit_counter.reset
    miss_counter.reset
  end
  def self.reset_stats = IpAddressApi.new.reset_stats

  def lookup(ip=nil)
    return {} if ip.nil?

    ip_data = Kredis.json(key_name(ip), expires_in: ttl)
    
    if ip_data.value.blank? && cache_only == true
      miss!
    elsif ip_data.value.blank? && cache_only == false
      miss!
      ip_data.value = JSON.parse( URI.open("https://api.incolumitas.com/?q=#{ip}", "User-Agent" => agent).read)
      ip_data.value ||= {}
    else
      hit!
    end

    return ip_data.value
  rescue OpenURI::HTTPError => e
    puts("IP Address API error looking up IP: #{ip} : #{e.inspect}")
    return {}
  end

  def self.prefix = 'IpAddressApi_'
  def self.agent = "Ruby/#{RUBY_VERSION}"
  def self.lookup(ip=nil, cache_only: false, agent: nil)
    IpAddressApi.new(cache_only:, agent:).lookup(ip)
  end

  private
  def hit!         = hit_counter.increment
  def miss!        = miss_counter.increment
end
```

## Usage

```ruby
> IpAddressApi.lookup('1.1.1.1')
> result.is_datacenter
=> false
> result.name
=> "CLOUDFLARENET, US"

> IpAddressApi.lookup(ip: '52.93.127.126')
> result.is_datacenter
=> true
> result.name
=> "Amazon AWS"

> IpAddressApi.lookup(ip: '27.32.20.97' )
> result.is_datacenter
=> false
> result.name
=> "TPG-INTERNET-AP TPG Telecom Limited, AU"
```

The cache records its hitrate:

```ruby
> c.hitrate
=> 0.6829268292682927
```
## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
