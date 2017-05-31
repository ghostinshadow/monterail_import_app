# frozen_string_literal: true

RSpec.describe FileFormatValidator do
  let(:formats) { [Mime::CSV] }
  subject do
    FileFormatValidator.new(attributes: [:file],
                            class: ImportForm, formats: formats)
  end

  it { is_expected.to be_kind_of(ActiveModel::EachValidator) }

  it 'accepts options' do
    expect(subject.options).to include(formats: [Mime::CSV])
  end

  it 'works for empty file attribute' do
    subject = FileFormatValidator.new(attributes: [:file])
    record = ImportForm.new

    subject.validate_each(record, :file, record.file)
  end

  describe '#validate_each' do
    context 'csv file' do
      let(:record) { build(:file_with_csv_format) }
      it 'not changes errors object if format is valid' do
        expect(subject).to receive(:valid_format?)
          .with(record.file, [Mime::CSV]).and_return(true)

        subject.validate_each(record, :file, record.file)
        expect(record.errors).to be_empty
      end

      it 'changes errors object if format is wrong' do
        expect(subject).to receive(:valid_format?)
          .with(record.file, [Mime::CSV]).and_return(false)

        subject.validate_each(record, :file, record.file)
        expect(record.errors.messages[:file])
          .to include('wrong format; text/csv should be given')
      end

      it 'adds error for not appropriate format' do
        subject.validate_each(record, :file, record.file)

        expect(record.errors).not_to be_empty
      end

      context 'valid type given' do
        let(:formats) { [Mime::CSV, 'text/comma-separated-values'] }
        it 'accepts valid format' do
          subject.validate_each(record, :file, record.file)

          expect(record.errors).to be_empty
        end
      end
    end
    context 'text file' do
      let(:record) { build(:file_with_txt_format) }

      it 'adds error to record' do
        subject.validate_each(record, :file, record.file)

        expect(record.errors).not_to be_empty
      end

      context 'valid type given' do
        let(:formats) { [Mime::TEXT] }

        it 'accepts valid format' do
          subject.validate_each(record, :file, record.file)

          expect(record.errors).to be_empty
        end
      end
    end
  end
end
