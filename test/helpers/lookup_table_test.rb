# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

# This file should contain all of the LookupTable records.
# The programming in this app (for performance and programming simplicity) usually finds a lookup table by its ID, not by lu_table and lu_id.
# For this to work properly, testing requires that the LookupTable is always loaded consistently to maintain identical autosequenced ID values
# To retain autosequenced ID values, the table it truncated and the identity restarted.
# This should be run in the setup for all tests requiring lookup tables.

# Note: consider using this to populate the LookupTables for production and development, so all environments are consistently equal

def lookup_table_test_load()

  # confirm environment is test environment
  raise "ERROR: this should only be run in the test environment" if !Rails.env.test?

  # clear LookupTable and reset identity autoincrement
  ActiveRecord::Base.connection.execute("TRUNCATE lookup_tables RESTART IDENTITY")

  LookupTableSeedHash::get_hash().each do |h|
    rec = FactoryBot.create(:lookup_table, h)
  end
  Rails.logger.info("CREATED #{LookupTable.count}")
  
  assert_equal(LookupTable.count, 199, "ERROR: LookupTableTest::load - Invalid LookupTable record count")
  assert_equal(LookupTable.last.id, 199, "ERROR: LookupTableTest::load - Invalid LookupTable record ids")
end

