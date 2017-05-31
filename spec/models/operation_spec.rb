# frozen_string_literal: true

RSpec.describe Operation do
  include_context 'import helpers'

  describe 'attributes' do
    it { is_expected.to respond_to(:invoice_num) }
    it { is_expected.to respond_to(:invoice_date) }
    it { is_expected.to respond_to(:operation_date) }
    it { is_expected.to respond_to(:amount) }
    it { is_expected.to respond_to(:reporter) }
    it { is_expected.to respond_to(:notes) }
    it { is_expected.to respond_to(:status) }
    it { is_expected.to respond_to(:kind) }
    it { is_expected.to respond_to(:company_id) }
    it { is_expected.to respond_to(:company) }
    it { is_expected.to respond_to(:categories) }
  end

  let(:errors) { subject.errors.full_messages }

  describe '#invoice_num' do
    it 'validates presence' do
      validate_presence_with_message('Invoice num can\'t be blank')
    end

    it 'validates uniqueness' do
      persisted_operation = create(:operation)
      subject.invoice_num = persisted_operation.invoice_num

      expect(subject).not_to be_valid
      expect(errors).to include('Invoice num has already been taken')
    end

    it 'accepts valid' do
      subject.invoice_num = 'S37753'

      validate_and_exclude_match(/Invoice num/)
    end
  end

  describe '#invoice_date' do
    it 'validates presence' do
      validate_presence_with_message('Invoice date can\'t be blank')
    end

    it 'validates date' do
      subject.invoice_date = 'not a date'

      validate_presence_with_message('Invoice date can\'t be blank')
    end

    it 'accepts valid' do
      subject.invoice_date = '29-04-2015'

      validate_and_exclude_match(/Invoice date/)
    end
  end

  describe '#amount' do
    it 'validates presence' do
      validate_presence_with_message('Amount can\'t be blank')
    end

    it 'validates numericallity' do
      subject.amount = 'not a number'

      expect(subject).not_to be_valid
      expect(errors).to include('Amount is not a number')
    end

    it 'validates positive numbers' do
      subject.amount = -5

      expect(subject).not_to be_valid
      expect(errors).to include('Amount must be greater than 0')
    end

    it 'accepts valid' do
      subject.amount = 7

      validate_and_exclude_match(/Amount/)
    end
  end

  describe '#operation_date' do
    it 'validates presence' do
      validate_presence_with_message('Operation date can\'t be blank')
    end

    it 'validates date' do
      subject.operation_date = 'not a date'

      validate_presence_with_message('Operation date can\'t be blank')
    end

    it 'accepts valid' do
      subject.operation_date = '29-04-2015'

      validate_and_exclude_match(/Operation date/)
    end
  end

  describe '#kind' do
    it 'validates presence' do
      validate_presence_with_message('Kind can\'t be blank')
    end

    it 'accepts valid' do
      subject.kind = 'negligible'

      validate_and_exclude_match(/Kind/)
    end
  end

  describe '#status' do
    it 'validates presence' do
      validate_presence_with_message('Status can\'t be blank')
    end

    it 'accepts valid' do
      subject.status = 'other'

      validate_and_exclude_match(/Status/)
    end
  end

  describe '#company' do
    it 'returns nil by default' do
      expect(subject.company).to be_nil
    end

    it 'returns company object' do
      subject = create(:operation)
      expect(subject.company).to be_an_instance_of(Company)
    end
  end

  describe '#categories' do
    let(:categories) { subject.categories }

    it 'returns empty array by default' do
      expect(categories).to be_empty
    end

    it 'stores only category objects' do
      expect { categories << 'string' }
        .to raise_error(ActiveRecord::AssociationTypeMismatch)
    end

    it 'returns associated categories' do
      category = build(:category)
      2.times { categories << category }

      expect(categories.size).to be == 2
      expect(categories.first).to be(category)
    end
  end

  describe '.import' do
    it 'accepts hash of parameters' do
      expect { Operation.import }.to raise_error(KeyError)
    end

    it 'triggers :foreach, :next, :each' do
      expect(CSV).to receive(:foreach).with(*foreach_params)

      Operation.import(import_params(csv_path))
    end

    it 'triggers :create_from_row 11 times' do
      expect(Operation).to receive(:create_from_row).exactly(11).times

      Operation.import(import_params(csv_path))
    end

    it 'yields 11 times' do
      expect{|b| Operation.import(import_params(csv_path), &b) }
        .to yield_control
    end

    it 'creates operations' do
      expect do
        Operation.import(import_params(csv_path, Company.available_resources))
      end
        .to change { Operation.count }.by(8)
    end
  end

  describe '.create_from_row' do
    let(:available_companies) do
      create(:microsoft)
      Company.all.as_json
    end

    it 'accepts hash' do
      expect { Operation.create_from_row }.to raise_error(KeyError)
    end

    it 'triggers conversion method on row' do
      row_dbl = double('CSV row', to_operation_attributes: true)
      operation_dbl = double('Operation double', save: true)

      allow(Operation).to receive(:new).and_return(operation_dbl)
      expected_attributes = { available_companies: [],
                              category_model: Category }
      expect(row_dbl)
        .to receive(:to_operation_attributes).with(expected_attributes)
      expect(operation_dbl).to receive(:save)

      Operation.create_from_row(row_params(row_dbl))
    end

    it 'creates operation' do
      Hash.include OperationCompatible
      row = build(:operation)
            .attributes.merge(kind: 'strong;loose', company: 'Microsoft',
                              operation_date: '11/11/2012',
                              invoice_date: '12/12/2025')

      expect { Operation.create_from_row(row_params(row, available_companies)) }
        .to change { Operation.count }.by(1)
      expect(Operation.last.company).to eq(Company.find_by(name: 'Microsoft'))
    end

    it 'triggers success callback if operation saved' do
      stub_operation_initialization
      allow_any_instance_of(Operation).to receive(:save).and_return(true)

      success_callback  = ->(e){ 1 }
      expect(success_callback).to receive(:call)

      Operation.create_from_row({row: {}, success_callback: success_callback})
    end
  end

  describe '#existing_categories=' do
    it 'adds categories based on input collection' do
      category = create(:category)
      operation = build(:operation)

      operation.existing_categories = [{ 'id' => category.id,
                                         'name' => category.name }]
      operation.save
      expect(operation.categories).to eq([category])
    end

    it 'does not collapse with accept_nested_attributes' do
      category = create(:category)
      operation = build(:operation)
      init_attributes = operation.attributes.merge(categories_attributes)

      operation = Operation.new(init_attributes)
      operation.existing_categories = [{ 'id' => category.id,
                                         'name' => category.name }]
      operation.save

      expect(operation.categories.order(name: :asc))
        .to eq([category,
                Category.find_by(name: 'strong'),
                Category.find_by(name: 'weak')])
    end
  end

  def stub_operation_initialization
    allow(Operation).to receive(:new).and_return(Operation.allocate)
    allow_any_instance_of(Hash).to receive(:to_operation_attributes)
  end

  def row_params(row, companies = [])
    { row: row,
      available_companies: companies,
      category_model: Category }
  end

  def categories_attributes
    { categories_attributes: [{ name: 'strong' }, { name: 'weak' }] }
  end

  def validate_presence_with_message(msg)
    expect(subject).not_to be_valid
    expect(errors).to include(msg)
  end

  def validate_and_exclude_match(regex)
    expect(subject).not_to be_valid
    expect(errors).not_to include(match(regex))
  end

  def foreach_params
    [csv_path, { headers: :first_row, return_headers: true, skip_blanks: true }]
  end
end
