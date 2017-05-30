# frozen_string_literal: true

FactoryGirl.define do
  factory :attachment, class: OperationImport do
    factory :file_with_txt_format do
      path = Rails.root.join('test', 'fixtures', 'import_example.txt')
      attributes = { tempfile: File.new(path),
                     filename: 'wrong_format.txt' }
      file ActionDispatch::Http::UploadedFile.new(attributes)
    end

    factory :file_with_csv_format do
      path = Rails.root.join('test', 'fixtures', 'import_example.csv')
      attributes = { tempfile: File.new(path),
                     filename: 'valid_file.csv' }
      file ActionDispatch::Http::UploadedFile.new(attributes)
    end
  end
end
