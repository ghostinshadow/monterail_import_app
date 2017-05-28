# frozen_string_literal: true

RSpec.describe Company do
  let(:errors) { subject.errors.full_messages }

  it_behaves_like 'name attribute owner'

  describe '#operations' do
    it 'returns empty array by default' do
      expect(subject.operations).to be_empty
    end

    it 'stores only operation objects' do
      expect { subject.operations << 'string' }
        .to raise_error(ActiveRecord::AssociationTypeMismatch)
    end

    it 'returns associated operations' do
      operation = build(:operation)
      subject.operations << operation

      expect(subject.operations.first).to be(operation)
    end
  end

  describe '.available_resources' do
    it 'returns empty array by default' do
      expect(Company.available_resources).to eq([])
    end

    it 'returns array of hashes' do
      create(:microsoft)

      expect(Company.available_resources.first)
        .to be_an_instance_of(Hash)
    end

    it 'returned hash has id and name keys' do
      company = create(:microsoft)

      expect(Company.available_resources.first)
        .to eq('id' => company.id, 'name' => company.name)
    end
  end
end
