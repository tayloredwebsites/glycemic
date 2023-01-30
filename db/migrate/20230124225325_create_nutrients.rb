class CreateNutrients < ActiveRecord::Migration[7.0]
  def up
    if !table_exists?(:nutrients)
      create_table :nutrients do |t|
        t.string :name
        t.integer :usda_ndb_num
        t.text :desc

        t.timestamps
      end
    end
  end

  def down
    drop_table :nutrients if !table_exists?(:nutrients)
  end
end
