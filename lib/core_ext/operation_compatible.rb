module OperationCompatible
  attr_writer :operation_attributes
  TIMESTAMPS = ["created_at", "updated_at"].freeze

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
    if operation_attributes[key].match(/(\d{2})\/(\d{2})\/(\d{4})/)
      operation_attributes[key] = "#{$3}-#{$1}-#{$2}"
    end
  end

  def add_company_id(available_companies)
    available_companies = Array(available_companies)
    company_name = operation_attributes.delete(:company)
    company = available_companies.find do |c|
      c.fetch("name") == (company_name&.strip)
    end
    operation_attributes[:company_id] = company&.fetch("id")
  end

  def add_embedded_categories(category_model)
    categories_names = Array(operation_attributes.fetch(:kind)&.split(";"))
    categories = categories_names.each_with_object([]) do |name, memo|
      memo << (category_model.find_or_initialize_by(name: name.downcase).attributes
      .except(*TIMESTAMPS))
    end
    id_existing_filter = ->(e) { e.fetch("id")}
    operation_attributes[:categories_attributes] = categories.reject(&id_existing_filter)
    operation_attributes[:existing_categories] = categories.select(&id_existing_filter)
  end
end
