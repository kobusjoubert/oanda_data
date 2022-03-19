module Charts
  class Candles < Chart
    REQUIRED_ATTRIBUTES = [:oanda_client, :instrument].freeze

    attr_accessor :oanda_client, :instrument, :granularity, :chart_interval, :count, :from, :to, :price, :include_incomplete_candles

    def initialize(options = {})
      super
      @count                      ||= 100 # FIXME attr_reader count does not return @count in function chart?
      @chart_interval             ||= 60
      @include_incomplete_candles ||= false
      @price                      ||= 'M'
      @granularity                ||= Definitions::Instrument.candlestick_granularity(chart_interval)
      @from                       = Time.new.api(from.utc) if from
      @to                         = Time.new.api(to.utc) if to
    end

    def chart
      options = { granularity: granularity, price: price }

      if from && to
        options[:from]  = from
        options[:to]    = to
        @count          = 0
      else
        options[:count] = include_incomplete_candles ? @count : @count + 1
      end

      candles = oanda_client.instrument(instrument).candles(options).show

      unless from && to
        candles['candles'].last['complete'] ? candles['candles'].shift : candles['candles'].pop unless include_incomplete_candles
      end

      raise OandaData::ChartError, "#{self.class} #{instrument} ERROR. No candles returned. candles: #{candles}; options: #{options}" if candles['candles'].empty?
      raise OandaData::ChartError, "#{self.class} #{instrument} ERROR. Not enough candles returned, #{@count} needed. candles: #{candles['candles'].count}; options: #{options}" if candles['candles'].count < @count
      candles
    end
  end
end
