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
      expect{hashlike_object.to_operation_attributes(available_companies)}
      .to raise_error(KeyError)
    end

    it "sends 3 methods to self" do
      set_kind

      expect(hashlike_object).to receive(:add_company_id).with(available_companies)
      expect(hashlike_object).to receive(:add_embedded_categories)
      expect(hashlike_object).to receive(:operation_attributes)

      hashlike_object.to_operation_attributes(available_companies)
    end

    it "adds company_id to attributes based on name" do
      set_kind
      set_company

      expect(hashlike_object.to_operation_attributes(available_companies))
      .to include({company_id: 8})
    end

    it "adds categories to attributes based on kind" do
      set_kind

      expect(hashlike_object.to_operation_attributes(available_companies))
      .to include({categories_attributes: [{name: "available"}, {name: "strong"}]})
    end

    it "handles sybolized companies" do
      set_kind

      expect{ hashlike_object.to_operation_attributes(symbolized_companies)}
      .to raise_error(KeyError)
    end
  end


  def set_kind
    hashlike_object[:kind] = "available;strong"
  end

  def set_company
    hashlike_object[:company] =  "Microsoft"
  end

  def available_companies
    [{"name" => "Google", "id" => 2}, {"name" => "Microsoft", "id" => 8}]
  end

  def symbolized_companies
    [{name: "Google", id: 2}, {name: "Microsoft", id: 8}]
  end
end
