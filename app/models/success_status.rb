# frozen_string_literal: true

# service object result
class SuccessStatus
  attr_reader :data
  def initialize(data)
    @data = data
  end

  def success?
    true
  end

  def message
    { type: 'success', message: data }
  end
end
