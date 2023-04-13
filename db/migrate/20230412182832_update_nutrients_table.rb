class UpdateNutrientsTable < ActiveRecord::Migration[7.0]
  # clean up of Nutrients table.
  # made this fully reversable and rerunnable. Did this because change_table is troublesome.
  def up
    change_column_null(:nutrients, :name, false)
    # change_column_default(:nutrients, :name, from: nil, to: '')
    rename_column(:nutrients, :usda_ndb_num, :usda_nutrient_id) if column_exists? :nutrients, :usda_ndb_num
    change_column_null(:nutrients, :usda_nutrient_id, false)
    change_column_null(:nutrients, :active, false)

    remove_column :nutrients, :desc if column_exists? :nutrients, :desc

    remove_column :nutrients, :unit if column_exists? :nutrients, :unit
    add_column :nutrients, :unit_code, :string, limit: 8, null: false unless column_exists? :nutrients, :unit_code
    add_column :nutrients, :rda, :float, null: true unless column_exists? :nutrients, :rda

    remove_index :nutrients, :usda_nutrient_num if index_exists?(:nutrients, :usda_nutrient_num)
    add_index :nutrients, :usda_nutrient_id unless index_exists?(:nutrients, :usda_nutrient_id)
    # unique index on nutrient name (and unit code to allow a separate entry for nutrients with different units e.g. calories vs kJ)
    remove_index :nutrients, :name if index_exists?(:nutrients, :name)
    add_index :nutrients, [:name, :unit_code], unique: true unless index_exists?(:nutrients, [:name, :unit_code])
  end

  def down
    change_column_null(:nutrients, :name, true)
    # change_column_default(:nutrients, :name, from: nil, to: '')
    rename_column(:nutrients, :usda_nutrient_id, :usda_ndb_num) if column_exists? :nutrients, :usda_nutrient_id
    change_column_null(:nutrients, :usda_ndb_num, true)
    change_column_null(:nutrients, :active, true)

    add_column :nutrients, :desc, :text unless column_exists? :nutrients, :desc

    add_column :nutrients, :unit unless column_exists? :nutrients, :unit
    remove_column :nutrients, :unit_code if column_exists? :nutrients, :unit_code
    remove_column :nutrients, :rda if column_exists? :nutrients, :rda

    # add_index :nutrients, :usda_nutrient_num, name: 'ix_nutrients_on_usda_nutrient_num' unless index_exists?(:nutrients, :usda_nutrient_num, name: 'ix_nutrients_on_usda_nutrient_num')
    remove_index :nutrients, :usda_nutrient_id if index_exists?(:nutrients, :usda_nutrient_id)
    add_index :nutrients, :name unless index_exists?(:nutrients, :name)
    remove_index :nutrients, [:name, :unit_code] if index_exists?(:nutrients, [:name, :unit_code])
  end
end
