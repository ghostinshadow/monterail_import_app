class Company < ActiveRecord::Base
  has_many :operations

  validates_presence_of :name

  def self.available_resources
    all.select(:id, :name).as_json
  end
end
