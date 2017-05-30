# frozen_string_literal: true

# named category
class Category < ApplicationRecord
  validates :name, presence: true
  has_and_belongs_to_many :operations
end
