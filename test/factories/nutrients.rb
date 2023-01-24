FactoryBot.define do
  factory :nutrient do
    id { 1 }
    name { "MyString" }
    usda_ndb_num { 1 }
    desc { "MyText" }
  end
end
