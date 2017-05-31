# frozen_string_literal: true

require 'csv'
# operation
class Operation < ApplicationRecord
  CSV_OPTIONS = {
    headers: :first_row,
    return_headers: true,
    skip_blanks: true
  }.freeze
  DEFAULT_CALLBACK = -> {}

  belongs_to :company
  has_and_belongs_to_many :categories
  accepts_nested_attributes_for :categories

  validates :invoice_num, presence: true, uniqueness: true
  validates :invoice_date, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :operation_date, presence: true
  validates :kind, presence: true
  validates :status, presence: true

  def self.import(hsh = {})
    CSV.foreach(hsh.fetch(:path), CSV_OPTIONS) do |row|
      create_from_row(hsh.except!(:path).merge!(row: row))
      yield if block_given?
    end
  end

  def self.create_from_row(hsh = {})
    operation = new hsh.fetch(:row)
                      .to_operation_attributes(hsh.except!(:row))
    if operation.save
      hsh.fetch(:success_callback, DEFAULT_CALLBACK).()
    else
      hsh.fetch(:failure_callback, DEFAULT_CALLBACK).()
    end
  end

  def existing_categories=(collection)
    Array(collection).each do |c|
      categories << Category.find_by(id: c['id'])
    end
  end
end
