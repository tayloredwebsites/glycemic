class CreateFoodNutrients < ActiveRecord::Migration[7.0]
  def change
    create_table :food_nutrients do |t|
      t.integer :nutrient_id
      t.integer :food_id
      t.boolean :study
      t.decimal :study_weight, precision: 4, scale: 2
      t.integer :avg_rec_id
      t.decimal :portion, precision: 6, scale: 2
      t.string :portion_unit
      t.decimal :amount, precision: 6, scale: 2
      t.string :amount_unit
      t.text :desc

      t.timestamps

      t.index :nutrient_id
      t.index :food_id
      t.index :study
    end
  end
end
