# frozen_string_literal: true

# file format validator
class FileFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    formats = Array(options[:formats])
    return true if valid_format?(value, formats)
    record.errors.add attribute, 'wrong format; '\
      "#{formats.join(',')} should be given"
  end

  def valid_format?(file, formats)
    return false unless validates_presence(file)
    mime_type_fix(file)
    validates_class(file) && matches_mime(file, formats)
  end

  def mime_type_fix(file)
    mime_type = MIME::Types.type_for(file.original_filename)
    file.content_type = mime_type.first.content_type if mime_type.first
  end

  def validates_presence(file)
    file.present?
  end

  def validates_class(file)
    file.is_a?(::ActionDispatch::Http::UploadedFile)
  end

  def matches_mime(file, mimes)
    mimes.include? file.content_type
  end
end
