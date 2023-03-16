class LookupTables < ActiveRecord::Migration[7.0]
  def up
    if !table_exists?(:lookup_tables)
      create_table :lookup_tables do |t|
        t.string :lu_table
        t.integer :lu_id
        t.string :lu_code, null: false, default: ""
        t.text :lu_desc, null: false, default: ""
        t.boolean :active, null: false, default: true

        t.timestamps

        t.index :lu_table, name: 'ix_lookup_tables_on_lu_table'
        t.index :lu_code, name: 'ix_lookup_tables_on_lu_code'
        t.index %i[lu_table lu_code], name: 'ix_lookup_tables_on_lu_table_lu_code', unique: true
      end
    end
  end

  def down
    drop_table :lookup_tables if table_exists?(:lookup_tables)
  end
end
