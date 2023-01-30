FactoryBot.define do
  factory :food_nutrient do
    association :food, factory: :food
    association :nutrient, factory: :nutrient
    study { false }
    study_weight { "1.0" }
    avg_rec_id { 1 }
    portion { "550" }
    portion_unit { "g" }
    amount { "3.5" }
    amount_unit { "mg" }
    desc { "" }
  end

end
