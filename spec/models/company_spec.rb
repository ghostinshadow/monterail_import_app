RSpec.describe Company do
  
  let(:errors){ subject.errors.full_messages }

  it_behaves_like "name attribute owner"

  describe "#operations" do
    it "returns empty array by default" do
      expect(subject.operations).to be_empty
    end

    it "stores only operation objects" do
      expect{ subject.operations << "string"}
      .to raise_error(ActiveRecord::AssociationTypeMismatch)
    end

    it "returns associated operations" do
      operation = build(:operation)
      subject.operations << operation

      expect(subject.operations.first).to be(operation) 
    end
  end
end