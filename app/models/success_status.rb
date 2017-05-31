# frozen_string_literal: true

class SuccessStatus
  attr_reader :data
  def initialize(data)
    @data = data
  end
  
  def success?
    true
  end
end
