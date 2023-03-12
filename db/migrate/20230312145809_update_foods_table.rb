class UpdateFoodsTable < ActiveRecord::Migration[7.0]
  def change
    change_table :foods do |t|
      t.integer :recipe_id
      t.boolean :public, null: false, default: true
      t.string :usda_upc_num, limit: 14, null: false, default: ''
      t.string :usda_food_cat_lu_id, limit: 4, null: false, default: ''
      t.string :wweia_food_cat_lu_id, limit: 4, null: false, default: ''
      t.string :usda_desc, null: false, default: ''
      t.string :usda_data_type, null: false, default: ''
      t.date :usda_pub_date

      t.index :recipe_id, unique: true, name: 'ix_foods_on_recipe_id'
      t.index :public, name: 'ix_foods_on_public'
      t.index :usda_food_cat_lu_id, name: 'ix_foods_on_usda_cat'
      t.index :wweia_food_cat_lu_id, name: 'ix_foods_on_wweia_cat'
    end

    change_column_null(:foods, :name, false)
    change_column_default(:foods, :name, from: nil, to: '')
    change_column_null(:foods, :desc, false)
    change_column_default(:foods, :desc, from: nil, to: '')
    change_column_null(:foods, :active, false)
  end
end
