json.extract! food_nutrient, :id, :nutrient_id, :food_id, :study, :study_weight, :avg_rec_id, :portion, :portion_unit, :amount, :amount_unit, :desc, :created_at, :updated_at, :errors
json.url food_nutrient_url(food_nutrient, format: :json)
