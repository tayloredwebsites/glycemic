json.extract! food, :id, :name, :desc, :usda_fdc_id, :created_at, :updated_at
json.url food_path(food, format: :json)
