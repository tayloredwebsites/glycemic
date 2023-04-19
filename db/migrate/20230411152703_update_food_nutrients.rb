class UpdateFoodNutrients < ActiveRecord::Migration[7.0]
  # clean up of foods table, fields not immediately needed are placed in samples_json field.
  # made this fully reversable and rerunnable. Did this because change_table is troublesome.
  def up

    change_column_null(:food_nutrients, :nutrient_id, false)
    # change_column_default(:food_nutrients, :nutrient_id, from: nil, to: '')
    change_column_null(:food_nutrients, :food_id, false)
    # change_column_default(:food_nutrients, :food_id, from: nil, to: '')

    remove_column :food_nutrients, :study if column_exists? :food_nutrients, :study
    remove_column :food_nutrients, :study_weight if column_exists? :food_nutrients, :study_weight
    remove_column :food_nutrients, :avg_rec_id if column_exists? :food_nutrients, :avg_rec_id
    # remove_column :food_nutrients, :portion_unit_code if column_exists? :food_nutrients, :portion_unit_code
    remove_column :food_nutrients, :amount_unit if column_exists? :food_nutrients, :amount_unit
    remove_column :food_nutrients, :desc if column_exists? :food_nutrients, :desc

    change_column :food_nutrients, :portion, :float
    change_column :food_nutrients, :amount, :float
    
    add_column :food_nutrients, :usda_nutrient_id, :integer, null: false unless column_exists? :food_nutrients, :usda_nutrient_id
    add_column :food_nutrients, :median, :float, null: true, default: nil unless column_exists? :food_nutrients, :median
    add_column :food_nutrients, :variance, :float, null: true, default: nil unless column_exists? :food_nutrients, :variance
    add_column :food_nutrients, :samples_json, :text, null: false, default: '' unless column_exists? :food_nutrients, :samples_json

    add_index :food_nutrients, :usda_nutrient_id, name: 'ix_food_nutrients_on_usda_nutrient_id' unless index_exists?(:food_nutrients, :usda_nutrient_id, name: 'ix_food_nutrients_on_usda_nutrient_id')
  end

  def down
    add_column :food_nutrients, :study, :boolean unless column_exists? :food_nutrients, :study
    add_column :food_nutrients, :study_weight, :decimal, precision: 4, scale: 2 unless column_exists? :food_nutrients, :study_weight
    add_column :food_nutrients, :avg_rec_id, :integer unless column_exists? :food_nutrients, :avg_rec_id
    # add_column :food_nutrients, :portion_unit_code, :string, limit: 8 unless column_exists? :food_nutrients, :portion_unit_code
    add_column :food_nutrients, :amount_unit, :string, limit: 4 unless column_exists? :food_nutrients, :amount_unit
    add_column :food_nutrients, :desc, :text unless column_exists? :food_nutrients, :desc

    change_column :food_nutrients, :portion, :decimal, precision: 6, scale: 2
    change_column :food_nutrients, :amount, :decimal, precision: 6, scale: 2
    
    remove_column :food_nutrients, :usda_nutrient_id if column_exists? :food_nutrients, :usda_nutrient_id
    remove_column :food_nutrients, :median if column_exists? :food_nutrients, :median
    remove_column :food_nutrients, :variance if column_exists? :food_nutrients, :variance
    remove_column :food_nutrients, :samples_json if column_exists? :food_nutrients, :samples_json

    add_index :food_nutrients, :usda_nutrient_num, name: 'ix_food_nutrients_on_usda_nutrient_num' if index_exists?(:food_nutrients, :usda_nutrient_num)
  end
end
