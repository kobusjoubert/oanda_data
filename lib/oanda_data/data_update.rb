# Note
#
#   We want candles from 2010-01-01T00:00 to 2010-01-01T23:00 for each file when downloading H1 candles.
#
class DataUpdate
  REQUIRED_ATTRIBUTES = [:instrument, :granularity].freeze
  AWS_REGION          = 'us-east-1'
  OANDA_ACCOUNT       = '001-001-123456-001'

  attr_accessor :oanda_client, :instrument, :granularity, :back
  attr_reader   :chart, :previous_day

  def initialize(options = {})
    options.symbolize_keys!
    missing_attributes = REQUIRED_ATTRIBUTES - options.keys
    raise ArgumentError, "The #{missing_attributes} attributes are missing" unless missing_attributes.empty?

    options.each do |key, value|
      self.send("#{key}=", value) if self.respond_to?("#{key}=")
    end

    unless oanda_client
      @worker_account = Account.find_by!(practice: false, account: OANDA_ACCOUNT)
      @oanda_client   = OandaApiV20.new(access_token: @worker_account.access_token, practice: @worker_account.practice)
    end

    @back         ||= 1
    now           = Time.now.utc
    offset        = now.hour.hours + now.min.minutes + now.sec.seconds
    @previous_day = now - offset - back.to_i.day

    # Candles returned are inclusive of the from date.
    # When this is -1.second, we could miss the first candle over weekends.
    # Example NZD_USD H1 2018-10-21. We only started getting candles from 2018-10-21T22:00 where we should've gotten from 2018-10-21T21:00.
    from          = now - offset - back.to_i.day # - 1.second
    to            = now - offset - back.to_i.day + 1.day
    @chart        = Charts::Candles.new(oanda_client: oanda_client, instrument: instrument, granularity: granularity, price: 'MAB', from: from, to: to)
  end

  def update_candles
    begin
      candles = chart.chart
      s3      = Aws::S3::Resource.new(region: AWS_REGION)
      file    = s3.bucket('oandadata').object("candles/#{chart.instrument}/#{chart.granularity}/#{previous_day.year}-#{format('%02d', previous_day.month)}-#{format('%02d', previous_day.day)}.json")
      file    = file.put(body: candles.to_json)
    rescue OandaApiV20::RequestError, Aws::S3::Errors::ServiceError => e
      data = { practice: false, account: OANDA_ACCOUNT, message: "Error when updating candles #{instrument} at granularity #{granularity}. #{e}" }
      $rabbitmq_exchange.publish(data.to_json, routing_key: 'qt_strategy_warnings')
      false
    end
    true
  end
end
