# frozen_string_literal: true

FactoryGirl.define do
  factory :operation do
    invoice_num 'S37753'
    invoice_date '29-04-2015'
    operation_date '21-04-2015'
    amount 15_491.15
    status 'other'
    kind 'negligible'
    notes 'Quas quibusdam quo molestiae doloribus ipsum sed.'
    reporter 'Abelardo Wehner'

    before(:build) do |operation|
      operation.company = create(:valid_company)
    end

    before(:create) do |operation|
      operation.company = create(:valid_company)
    end
  end
end
