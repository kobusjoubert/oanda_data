class DataRunWorker
  include Sneakers::Worker
  from_queue :qd_data_run

  def work(msg)
    data = JSON.parse(msg)
    DataRun.new(data).send(data[:action]) ? ack! : requeue!
  end
end
