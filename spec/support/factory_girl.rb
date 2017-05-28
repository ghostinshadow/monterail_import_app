# frozen_string_literal: true

require 'English'

module ExtendedMethods
  def create(*args, &block)
    super
  rescue => e
    raise unless e.is_a? ActiveRecord::RecordInvalid
    raise $ERROR_INFO, "#{e.message} (Class #{e.record.class.name}",
          $ERROR_INFO.backtrace
  end
end

module FactoryGirl
  module Syntax
    module Methods
      prepend ExtendedMethods
    end
  end
end

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
