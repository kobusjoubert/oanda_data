class DataRun
  REQUIRED_ATTRIBUTES = [:action, :instruments].freeze

  attr_accessor :action, :instruments, :back
  attr_reader   :oanda_client

  def initialize(options = {})
    options.symbolize_keys!
    missing_attributes = REQUIRED_ATTRIBUTES - options.keys
    raise ArgumentError, "The #{missing_attributes} attributes are missing" unless missing_attributes.empty?

    options.each do |key, value|
      self.send("#{key}=", value) if self.respond_to?("#{key}=")
    end

    @back           ||= 1
    @worker_account = Account.find_by!(practice: false, account: DataUpdate::OANDA_ACCOUNT)
    @oanda_client   = OandaApiV20.new(access_token: @worker_account.access_token, practice: @worker_account.practice)
  end

  def run_data_updates
    instruments.each do |instrument, granularities|
      granularities.each do |granularity|
        $logger.info "Retrieving #{instrument} #{granularity} #{back}..."
        data = { oanda_client: oanda_client, instrument: instrument, granularity: granularity, back: back }

        for i in 0..5
          begin
            break if DataUpdate.new(data).update_candles
          rescue OandaData::ChartError, NoMethodError => e # When no candles were found.
            $logger.warn "ERROR while retrieving #{instrument} #{granularity}. #{e}"
            break
          rescue Timeout::Error, Exception => e
            $logger.warn "ERROR while retrieving #{instrument} #{granularity}. #{e}"
          end
        end
      end
    end
  end
end
