# DatacenterDetector
Use the Gem to determine if an IP Address belongs to a  datacenter network range. Response will usually include the CIDR of the queried network the IP belongs to. 

This Gem wouldn't be possble without the work done here : https://incolumitas.com/pages/Datacenter-IP-API/

Responses are cached, including the supplied netblock, in SQLite. Subsequent lookups which are within the same netblock will be cached. 

To experiment with DatacenterDetector, run `bin/console` for an interactive prompt.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add datacenter_detector

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install datacenter_detector

## Usage

```ruby
> client = DatacenterDetector::Client.new
> result = client.query(ip: '1.1.1.1')
> result.is_datacenter
=> false
> result.name
=> "CLOUDFLARENET, US"

> result = client.query(ip: '52.93.127.126')
> result.is_datacenter
=> true
> result.name
=> "Amazon AWS"

> result = client.query(ip: '27.32.20.97' )
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

## TODO
Networks are cached by finding the first and last IP in the range and converting them to integers. This library does not detect overlapping networks.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/datacenter_detector.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
