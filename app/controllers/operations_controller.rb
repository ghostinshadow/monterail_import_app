# frozen_string_literal: true

# operations controller
class OperationsController < ApplicationController
  def index; end

  def import
    form = ImportForm.new(import_data_params)
    service_params = { category_model: Category, form: form,
                       available_companies: Company.available_resources }
    result = ImportOperations.new(service_params).call
    PrivatePub.publish_to('/status/messages', result.message)
  end

  private

  def import_data_params
    params.require(:import_data).permit(:file)
  rescue ActionController::ParameterMissing
    PrivatePub.publish_to('/status/messages',
                          type: 'danger', message: 'Provide a file')
  end
end
