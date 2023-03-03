class AddActiveToTables < ActiveRecord::Migration[7.0]
  def change
    add_column :food_nutrients, :active, :boolean, default: true
    add_column :foods, :active, :boolean, default: true
    add_column :nutrients, :active, :boolean, default: true
    add_column :users, :active, :boolean, default: true
  end
end
