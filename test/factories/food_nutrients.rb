FactoryBot.define do
  factory :food_nutrient do
    id { 1 }
    nutrient_id { 1 }
    food_id { 1 }
    study { false }
    study_weight { "9.99" }
    avg_rec_id { 1 }
    portion { "9.99" }
    portion_unit { "MyString" }
    amount { "9.99" }
    amount_unit { "MyString" }
    desc { "MyText" }
  end
end
