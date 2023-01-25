FactoryBot.define do
  factory :nutrient do
    sequence(:name) { |n| "nutrient #{n}"}
    sequence(:usda_ndb_num) { |n| n}
    sequence(:desc) { |n| "Nutrient Description #{n}"}
  end
end
