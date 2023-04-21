class UpdateFoodsTable2 < ActiveRecord::Migration[7.0]
  # clean up of foods table, fields not immediately needed are placed in samples_json field.
  # made this fully reversable and rerunnable. Did this because change_table is troublesome.
  def up
    remove_column :foods, :desc if column_exists? :foods, :desc
    remove_column :foods, :usda_pub_date if column_exists? :foods, :usda_pub_date
    # remove_column :foods, :usda_fdc_id if column_exists? :foods, :usda_fdc_id
    remove_column :foods, :usda_data_type if column_exists? :foods, :usda_data_type
    remove_column :foods, :usda_upc_num if column_exists? :foods, :usda_upc_num
    remove_column :foods, :usda_desc if column_exists? :foods, :usda_desc
    add_column :foods, :unit, :string, limit: 4, null: false, default: '' unless column_exists? :foods, :unit
    add_column :foods, :samples_json, :text, null: true, default: '' unless column_exists? :foods, :samples_json

    # use consistent LookupTable id field for both of the food category lookups
    remove_index :foods, :usda_food_cat_lu_id if index_exists?(:foods, :usda_food_cat_lu_id)
    remove_column :foods, :usda_food_cat_lu_id if column_exists? :foods, :usda_food_cat_lu_id
    remove_column :foods, :usda_food_cat_id if column_exists? :foods, :usda_food_cat_id
    add_column :foods, :usda_food_cat_id, :integer unless column_exists? :foods, :usda_food_cat_id
    add_index :foods, :usda_food_cat_id, name: 'ix_foods_on_usda_cat' unless index_exists?(:foods, :usda_food_cat_id)

    remove_index :foods, :wweia_food_cat_lu_id if index_exists?(:foods, :wweia_food_cat_lu_id)
    remove_column :foods, :wweia_food_cat_lu_id if column_exists? :foods, :wweia_food_cat_lu_id
    remove_column :foods, :wweia_food_cat_id if column_exists? :foods, :wweia_food_cat_id
    add_column :foods, :wweia_food_cat_id, :integer unless column_exists? :foods, :wweia_food_cat_id
    add_index :foods, :wweia_food_cat_id, name: 'ix_foods_on_wweia_cat' unless index_exists?(:foods, :wweia_food_cat_id)

    # allow lookups by food name.  duplicates information will be kept in samples.json field
    add_index :foods, :name, unique: false, name: 'ix_foods_on_name' unless index_exists?(:foods, :name, name: 'ix_foods_on_name')
  end

  def down
    add_column :foods, :desc, :string, default: "", null: false unless column_exists? :foods, :desc
    add_column :foods, :usda_pub_date, :date unless column_exists? :foods, :usda_pub_date
    # add_column :foods, :usda_fdc_id, :integer unless column_exists? :foods, :usda_fdc_id
    add_column :foods, :usda_data_type, :string, default: "", null: false unless column_exists? :foods, :usda_data_type
    add_column :foods, :usda_upc_num, :string unless column_exists? :foods, :usda_upc_num
    add_column :foods, :usda_desc, :text unless column_exists? :foods, :usda_desc
    remove_column :foods, :unit if column_exists? :foods, :unit
    remove_column :foods, :samples_json if column_exists? :foods, :samples_json

    remove_index :foods, :name, name: 'ix_foods_on_name' if index_exists?(:foods, :name, name: 'ix_foods_on_name')
  end
end
