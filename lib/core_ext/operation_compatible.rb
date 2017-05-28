# frozen_string_literal: true

# converter to operation attributes
module OperationCompatible
  attr_writer :operation_attributes
  TIMESTAMPS = %w[created_at updated_at].freeze
  ID_FILTER = ->(e) { e.fetch('id') }

  def operation_attributes
    @operation_attributes ||= to_h.symbolize_keys
  end

  def to_operation_attributes(available_companies, category_model)
    add_company_id(available_companies)
    add_embedded_categories(category_model)
    reform_invalid_dates
    operation_attributes
  end

  private

  def reform_invalid_dates
    reform_invalid_date(:operation_date)
    reform_invalid_date(:invoice_date)
  end

  def reform_invalid_date(key)
    return unless operation_attributes[key]
    wrong_date_format = %r{(?<month>\d{2})/(?<day>\d{2})/(?<year>\d{4})}
    operation_attributes[key].match(wrong_date_format) do |matched|
      new_format = "#{matched['year']}-#{matched['month']}-#{matched['day']}"
      assign_attribute(key) { new_format }
    end
  end

  def add_company_id(available_companies)
    available_companies = Array(available_companies)
    company_name = operation_attributes.delete(:company)
    company = available_companies.find do |c|
      c.fetch('name') == (company_name&.strip)
    end
    assign_attribute(:company_id) { company&.fetch('id') }
  end

  def add_embedded_categories(category_model)
    categories_names = Array(operation_attributes.fetch(:kind)&.split(';'))
    categories = categories_names.each_with_object([]) do |name, memo|
      model = category_model.find_or_initialize_by(name: name.downcase)
      memo << model.attributes.except(*TIMESTAMPS)
    end
    assign_attribute(:categories_attributes) { categories.reject(&ID_FILTER) }
    assign_attribute(:existing_categories) { categories.select(&ID_FILTER) }
  end

  def assign_attribute(key)
    operation_attributes[key] = yield
  end
end
