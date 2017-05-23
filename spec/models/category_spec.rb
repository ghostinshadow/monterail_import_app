RSpec.describe Category do
  let(:errors){ subject.errors.full_messages }

  it_behaves_like "name attribute owner"

  describe "#operations" do
    let(:operations){ subject.operations }

    it "returns empty array by default" do
      expect(operations).to be_empty
    end

    it "stores only operation objects" do
      expect{ operations << "string"}
      .to raise_error(ActiveRecord::AssociationTypeMismatch)
    end

    it "returns associated operations" do
      operation = build(:operation)
      2.times { operations << operation }

      expect(operations.size).to be == 2
      expect(operations.first).to be(operation)
    end
  end
end
