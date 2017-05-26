RSpec.describe OperationCompatible do
  let(:hashlike_object){ Hash.include OperationCompatible; {} }
  let(:other_object){ Array.include OperationCompatible; []}

  describe "#operation_attributes" do
    it "returns self with symbolized keys" do
      hashlike_object["company"] = "Microsoft"

      expect(hashlike_object.operation_attributes).to eq({company: "Microsoft"})
    end

    it "returns empty hash" do
      expect(other_object.operation_attributes).to eq({})
    end
  end

  describe "#to_operation_attributes" do
    it "expects argument" do
      expect{ hashlike_object.to_operation_attributes }.to raise_error(ArgumentError)
    end

    it "requires kind attribute to be set" do
      expect{hashlike_object.to_operation_attributes(available_companies, Category)}
      .to raise_error(KeyError)
    end

    it "sends 3 methods to self" do
      set_kind

      expect(hashlike_object).to receive(:add_company_id).with(available_companies)
      expect(hashlike_object).to receive(:add_embedded_categories)
      expect(hashlike_object).to receive(:operation_attributes)
      expect(hashlike_object).to receive(:reform_invalid_dates)

      hashlike_object.to_operation_attributes(available_companies, Category)
    end

    it "adds company_id to attributes based on name" do
      set_kind
      set_company

      expect(hashlike_object.to_operation_attributes(available_companies, Category))
      .to include({company_id: 8})
    end

    it "adds categories to attributes based on kind" do
      set_kind

      expect(hashlike_object.to_operation_attributes(available_companies, Category))
      .to include({categories_attributes: [category_attributes_base("available"),
                                           category_attributes_base("strong")]})
    end

    it "adds categories ids if category exists" do
      category = create(:category)
      set_kind

      expect(hashlike_object.to_operation_attributes(available_companies, Category))
      .to include({categories_attributes: [category_attributes_base("strong")],
      				existing_categories: [category.attributes.except(*timestamps)]})
    end


    it "adds categories ids if category exists with different case" do
      category = create(:category)
      set_kind("Available;strong")

      expect(hashlike_object.to_operation_attributes(available_companies, Category))
      .to include({categories_attributes: [category_attributes_base("strong")],
      				existing_categories: [category.attributes.except(*timestamps)]})
    end

    it "handles sybolized companies" do
      set_kind

      expect{ hashlike_object.to_operation_attributes(symbolized_companies, Category)}
      .to raise_error(KeyError)
    end

    it "reforms date MM/DD/YYYY" do
      set_kind
      set_company
      set_operation_date("12/28/2012")
      set_invoice_date("12/27/2012")

      attributes = hashlike_object.to_operation_attributes(available_companies, Category)
      subject = Operation.new(attributes)
      expect(subject).not_to be_valid
      expect(subject.errors.full_messages)
      .not_to include(match(/Operation date/))
    end

    it "passes along date with YYYY-MM-DD format" do
      set_kind
      set_company
      set_operation_date("2012-11-24")
      set_invoice_date("2012-10-24")

      attributes = hashlike_object.to_operation_attributes(available_companies, Category)
      subject = Operation.new(attributes)
      expect(subject).not_to be_valid
      expect(subject.errors.full_messages)
      .not_to include(match(/Operation date/), match(/Invoice date/))
    end

    it "passes along date with DD-MM-YYYY format" do
      set_kind
      set_company
      set_operation_date("17-10-2012")
      set_invoice_date("19-09-2012")

      attributes = hashlike_object.to_operation_attributes(available_companies, Category)
      subject = Operation.new(attributes)
      expect(subject).not_to be_valid
      expect(subject.errors.full_messages)
      .not_to include(match(/Operation date/), match(/Invoice date/))
    end
  end

  def timestamps
    ["created_at", "updated_at"]
  end

  def category_attributes_base(name)
    Category.new(name: name).attributes.except("created_at", "updated_at")
  end

  def set_kind(value = "available;strong")
    hashlike_object[:kind] = value
  end

  def set_company
    hashlike_object[:company] =  "Microsoft"
  end

  def set_operation_date(value)
    hashlike_object[:operation_date] = value
  end

  def set_invoice_date(value)
    hashlike_object[:invoice_date] = value
  end

  def available_companies
    [{"name" => "Google", "id" => 2}, {"name" => "Microsoft", "id" => 8}]
  end

  def symbolized_companies
    [{name: "Google", id: 2}, {name: "Microsoft", id: 8}]
  end
end
