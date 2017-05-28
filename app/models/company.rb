# frozen_string_literal: true

# named company
class Company < ActiveRecord::Base
  has_many :operations

  validates :name, presence: true

  def self.available_resources
    all.select(:id, :name).as_json
  end
end
