# frozen_string_literal: true

# class for active record extensions
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
