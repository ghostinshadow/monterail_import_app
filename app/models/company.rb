# frozen_string_literal: true

# named company
class Company < ApplicationRecord
  has_many :operations

  validates :name, presence: true

  def self.available_resources
    all.select(:id, :name).as_json
  end
end
