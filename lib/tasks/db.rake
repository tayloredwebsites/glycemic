namespace :db do
  desc "reset minitest postgres pk sequence"
  # fix for ActiveRecord::RecordNotUnique: PG::UniqueViolation when running tests
  task reset_test_seq_ids: :environment do
    Rails.env = 'staging'
    ActiveRecord::Base.connection.tables.each do |t|
      Rails.logger.debug("reset_pk_sequence! for #{t.inspect}")
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
    end
  end
end
