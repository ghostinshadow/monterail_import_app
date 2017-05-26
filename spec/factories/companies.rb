FactoryGirl.define do
  factory :company do
    name nil
    factory :valid_company do
      name "SB Komputery"
    end

    factory :microsoft do
      name "Microsoft"
    end
  end
end
