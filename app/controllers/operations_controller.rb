# frozen_string_literal: true

# operations controller
class OperationsController < ApplicationController
  def index; end

  def import
    form = ImportForm.new(import_data_params)
    result = ImportOperations.new({ available_companies: Company.available_resources,
                          category_model: Category, form: form }).call
    if result.success?
      PrivatePub.publish_to('/status/messages', type: 'success', message: result.data)
    else
      PrivatePub.publish_to('/status/messages', type: 'danger', message: result.error)
    end
  end

  private

  def import_data_params
    params.require(:import_data).permit(:file)
  rescue ActionController::ParameterMissing
    PrivatePub.publish_to('/status/messages', {type: 'danger', message: 'Provide a file'})
  end
end
