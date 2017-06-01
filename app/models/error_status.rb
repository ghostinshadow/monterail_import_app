# frozen_string_literal: true

# result of service object
class ErrorStatus
  attr_reader :error
  def initialize(error)
    @error = error
  end

  def success?
    false
  end

  def message
    { type: 'danger', message: error }
  end
end
