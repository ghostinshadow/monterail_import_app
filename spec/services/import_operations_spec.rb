# frozen_string_literal: true

RSpec.describe ImportOperations do
  include_context 'import helpers'

  it { expect{ subject }.to raise_error(KeyError)}
  let(:valid_operation) { ImportOperations.new(import_params(valid_form)) }
  let(:invalid_operation) { ImportOperations.new(import_params(invalid_form)) }

  describe 'attributes' do
    subject { valid_operation }

    it { is_expected.to respond_to(:call) }
  end

  describe '#call' do
    before(:example) { stub_private_pub }

  	it 'returns error response if form not valid' do
      expect(invalid_operation.call).to be_an_instance_of(ErrorStatus)
  	end

    it 'returns changes successes counter by 8(valid rows)' do
      expect{ valid_operation.call }.to change{ valid_operation.successes }.by(8)
    end

    it 'changes failures counter by 3(invalid rows)' do
      expect{ valid_operation.call }.to change{ valid_operation.failures }.by(3)
    end

    it 'returns statistics in imported data' do
      result = valid_operation.call
      expect(result).to be_an_instance_of(SuccessStatus)

      expect(result.data).to eq(statistics(8, 3, 11))
    end

    it 'calculates file size' do
      result = valid_operation.call
      expect(result.data[:file_size]).to eq(11)
    end

    it 'resets counters' do
      valid_operation.call
      result = valid_operation.call
      expect(result.data).to eq(statistics(0, 11, 11))
    end

    it 'sends block to import' do
      expect(PrivatePub).to receive(:publish_to).exactly(11).times
      valid_operation.call
    end
  end

  describe '#publish_statistics' do
    it 'sends statistics to channel using PrivatePub' do
      allow(PrivatePub).to receive(:publish_to).with('/channel', statistics(0,0,0))
      valid_operation.publish_statistics('/channel')
    end
  end

  def stub_private_pub
    allow(PrivatePub).to receive(:publish_to)
  end

  def statistics(succ, fail, size)
    { successes: succ, failures: fail, file_size: size }
  end

  def import_params(record, companies = [])
    { form: record,
      available_companies: companies,
      category_model: Category }
  end

  def valid_form
    build(:file_with_csv_format)
  end

  def invalid_form
    build(:file_with_txt_format)
  end
end
