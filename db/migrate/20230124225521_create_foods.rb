class CreateFoods < ActiveRecord::Migration[7.0]
  def up
    if !table_exists?(:foods)
      create_table :foods do |t|
        t.string :name
        t.text :desc
        t.integer :usda_fdc_id

        t.timestamps
      end
    end
  end

  def down
    drop_table :foods if !table_exists?(:foods)
  end
end
