require 'csv'

class Operation < ActiveRecord::Base
  CSV_OPTIONS = {headers: :first_row,
                 return_headers: true,
                 skip_blanks: true}.freeze

  belongs_to :company
  has_and_belongs_to_many :categories
  accepts_nested_attributes_for :categories

  validates_presence_of :invoice_num, :invoice_date, :amount, :operation_date, :kind, :status
  validates_numericality_of :amount, greater_than: 0
  validates_uniqueness_of :invoice_num

  def self.import(path, available_companies, category_model)
    CSV.foreach(path, CSV_OPTIONS) do |row|
      create_from_row(row, available_companies, category_model)
    end
  end

  def self.create_from_row(row, available_companies, category_model)
    e = new row.to_operation_attributes(available_companies, category_model)
    e.save
  end

  def existing_categories=(collection)
    Array(collection).each do |c|
      categories << Category.find_by(id: c["id"])
    end
  end
end
