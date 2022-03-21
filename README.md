# OandaData

Download candle data from [Oanda](https://developer.oanda.com/rest-live-v20/instrument-ep/) to be used for backtesting through the [Oanda Trader](https://github.com/kobusjoubert/oanda_trader) user interface.

## Usage

Set your AWS account environment variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` for writing to AWS S3 buckets.

Update the `OANDA_ACCOUNT` constant in class `DataUpdate` to your Oanda account ID to be used to download candles from.

### Backtesting

Download instrument candles

    for i in 1.100
      begin
        DataUpdate.new(instrument: 'EUR_USD', granularity: 'H4', back: i).update_candles
      rescue Exception => e
        if e.message.include?('No candles returned')
          p 'Weekend...'
        else
          p "Exception at #{i}: #{e}"
        end
      end
    end

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kobusjoubert/oanda_data.
