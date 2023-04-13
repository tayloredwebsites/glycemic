class RemoveUnitFromFood < ActiveRecord::Migration[7.0]
  # clean up of Nutrients table.
  # made this fully reversable and rerunnable. Did this because change_table is troublesome.
  def up
    remove_column :foods, :unit if column_exists? :foods, :unit
  end

  def down
    add_column :foods, :unit, :string, limit: 4 unless column_exists? :foods, :unit
  end
end
