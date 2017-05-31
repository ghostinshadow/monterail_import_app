# frozen_string_literal: true

class ImportOperations
  attr_accessor :failures, :successes, :file_size
  WEBSOCKET_CHANNEL = '/import/status'

  def initialize(hsh = {})
    @form = hsh.fetch(:form)
    @category_model = hsh.fetch(:category_model)
    @available_companies = hsh.fetch(:available_companies)
    @successes = @failures = @file_size = 0
    @success_callback = -> { increment_successes }
    @failure_callback = -> { increment_failures }
  end

  def call
    return ErrorStatus.new(error_message) unless form.valid?
    reset_counters
    calculate_file_size
    Operation.import(import_attributes) do
      publish_statistics(WEBSOCKET_CHANNEL)
    end
    SuccessStatus.new(statistics)
  end

  def publish_statistics(channel)
    PrivatePub.publish_to(channel, statistics)
  end

  private

  def increment_successes
    self.successes += 1
  end

  def increment_failures
    self.failures += 1
  end

  def increment_file_size
    self.file_size += 1
  end

  def reset_counters
    self.successes = 0
    self.failures = 0
    self.file_size = 0
  end

  def calculate_file_size
    CSV.foreach(form.to_path,
                Operation::CSV_OPTIONS) {|_| increment_file_size }
  end

  def statistics
    { successes: successes,
      failures: failures,
      file_size: file_size }
  end

  def error_message
    'CSV file should be provided'
  end
  
  attr_reader :form, :category_model, :available_companies,
              :success_callback, :failure_callback

  def import_attributes
    { path: form.to_path,
      available_companies: available_companies,
      category_model: category_model,
      success_callback: success_callback,
      failure_callback: failure_callback }
  end
end