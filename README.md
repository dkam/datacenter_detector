# DatacenterDetector
This Gem wouldn't be possble without the work done here : https://incolumitas.com/pages/Datacenter-IP-API/

The gem caches responses in SQLite.

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/datacenter_detector.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
