module OperationCompatible
  attr_writer :operation_attributes

  def operation_attributes
    @operation_attributes ||= to_h.symbolize_keys
  end

  def to_operation_attributes(available_companies)
    add_company_id(available_companies)
    add_embedded_categories
    operation_attributes
  end

  private

  def add_company_id(available_companies)
    available_companies = Array(available_companies)
    company_name = operation_attributes.delete(:company)
    company = available_companies.find{|e| e.fetch("name") == company_name}
    operation_attributes[:company_id] = company.fetch("id") if company
  end

  def add_embedded_categories
    categories_names = operation_attributes.fetch(:kind).split(";")
    categories = categories_names.each_with_object([]) do |name, memo|
      memo << {name: name}
    end
    operation_attributes[:categories_attributes] = categories
  end
end
