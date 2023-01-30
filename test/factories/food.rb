FactoryBot.define do
  factory :food do
    sequence(:name) { |n| "Food #{n}"}
    sequence(:desc) { |n| "Food Description #{n}"}
    sequence(:usda_fdc_id) { |n| n}
  end
end
