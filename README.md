# OandaData

Download candle data from Oanda to be used for backtesting through the Oanda Trader user interface.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'oanda_data'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install oanda_data

## Usage

Set your AWS account environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` for writing to AWS S3 buckets.

Update the `OANDA_ACCOUNT` constant in class `DataUpdate` to your Oanda account ID to be used to download candles from.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/oanda_data.

