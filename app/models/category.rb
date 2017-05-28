# frozen_string_literal: true

# named category
class Category < ActiveRecord::Base
  validates :name, presence: true
  has_and_belongs_to_many :operations
end
