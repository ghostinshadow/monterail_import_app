module ExtendedMethods
  def create(*args, &block)
    super
  rescue => e
    raise unless e.is_a? ActiveRecord::RecordInvalid
    raise $!, "#{e.message} (Class #{e.record.class.name}", $!.backtrace
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
