module OandaData
  class Error < StandardError; end
  class RecordNotFound < Error; end
  class ZeroNotAllowed < Error; end
  class ChartError < Error; end
  class DataRunError < Error; end
end
