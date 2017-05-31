# frozen_string_literal: true

RSpec.describe ImportForm do
  describe 'attributes' do
    it { is_expected.to respond_to(:valid?) }
    it { is_expected.to respond_to(:file) }
    it { is_expected.to respond_to(:to_path) }
  end

  describe '#file' do
    it 'rejects empty field' do
      is_expected.not_to be_valid
    end

    it 'rejects txt file' do
      record = build(:file_with_txt_format)
      expect(record).not_to be_valid
    end

    it 'accepts csv file' do
      record = build(:file_with_csv_format)
      expect(record).to be_valid
    end
  end

  describe '#to_path' do
    it 'returns file path' do
      record = build(:file_with_txt_format)
      expect(record.to_path).to eq(record.file.path)
    end
  end
end
