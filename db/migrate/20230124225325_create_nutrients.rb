class CreateNutrients < ActiveRecord::Migration[7.0]
  def change
    create_table :nutrients do |t|
      t.integer :id
      t.string :name
      t.integer :usda_ndb_num
      t.text :desc

      t.timestamps
    end
  end
end
