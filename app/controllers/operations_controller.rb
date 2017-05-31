# frozen_string_literal: true

# operations controller
class OperationsController < ApplicationController
  def index; end

  def import
    form = ImportForm.new(import_data_params)
    # binding.pry
    # PrivatePub.publish_to(ImportOperations::WEBSOCKET_CHANNEL, message: {a: 1})
    ImportOperations.new({ available_companies: Company.available_resources,
                          category_model: Category, form: form }).call
  end

  private

  def import_data_params
    params.require(:import_data).permit(:file)
  end
end
