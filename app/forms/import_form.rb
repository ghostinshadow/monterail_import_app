# frozen_string_literal: true

# form object
class ImportForm
  include ActiveModel::Validations
  CSV_FORMAT = 'text/comma-separated-values'

  attr_accessor :file

  validates :file, presence: true,
                   file_format: { formats: [Mime::CSV, CSV_FORMAT] }

  def initialize(options = {})
    self.file = options.fetch(:file, nil)
  end

  def to_path
	file.path
  end
end
