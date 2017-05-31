# frozen_string_literal: true

class ErrorStatus
  attr_reader :error
  def initialize(error)
    @error = error
  end
  
  def success?
    false
  end
end