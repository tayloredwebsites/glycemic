# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

require 'smarter_csv'
class ImportUsdaCsvFiles
  def self.perform()
    serv_obj = self.new()
    serv_obj.run()
  end

  def initialize()
    @report = Array.new()
    @errors = Array.new()
  end

  def run()

    # all of the uploads should be rerunnable.
    # check to see if record exists by looking for the record based upon its primary specification fields (primary keys).
    # If not found, add it, otherwise update all fields except the primary specification fields

    import_usda_categories()
    import_wweia_categories()

    return @report, @errors
    
  end

  def import_usda_categories()
    @report << ''
    msg = "Start of Importing of USDA Categories"
    Rails.logger.debug("*** #{msg}")
    @report << msg
    start_rec_count = LookupTable.all.count
    # read in usda categories into lookup tables:
    filename = Rails.root.join('db','csv_uploads','food_category.csv')
    chunk_size = 10
    chunk_num = 0
    options = {:chunk_size => chunk_size} # {:key_mapping => {:unwanted_row => nil, :old_row_name => :new_name}}
    n = SmarterCSV.process(filename, options) do |array|
      array.each_with_index do |row, ix|
        Rails.logger.debug("@@@ read line #{row.inspect}")
        rec_num = chunk_num*chunk_size + ix + 1
        msg = ''
        matching = LookupTable.where(lu_table: 'usda_cat', lu_code: row[:code])
        if matching.count == 1
          rec = matching.first
          rec.lu_id = row[:id]
          rec.lu_desc = row[:description]
          if rec.changed
            rec.save
            if rec.errors.count > 0
              msg = "Error writing USDA Category table row:#{rec_num} - #{rec.errors}"
              @errors << err_str
            else
              msg = "Updated row:#{rec_num} - #{rec[:id]},#{rec[:lu_code]}, #{rec[:lu_desc]}"
            end
          else
            # no need to update it, as it has not changed
          end
        else
          rec = LookupTable.new(
            lu_table: 'usda_cat',
            lu_code: row[:code],
            lu_id: row[:id],
            lu_desc: row[:description],
          )
          rec.save
          if rec.errors.count > 0
            msg = "Error writing USDA Category table row:#{rec_num} - #{rec.errors}"
            @errors << err_str
          else
            msg = "Added row:#{rec_num} - #{rec[:lu_code]}, #{rec[:lu_desc]}"
          end
        end
        @report << msg
      end
      chunk_num += 1
    end
    diff_num_recs = LookupTable.all.count - start_rec_count
    msg = "# imported #{diff_num_recs} new records from USDA Categories"
    Rails.logger.info("***" + msg)
    @report << msg
    Rails.logger.error("ERROR: #{@errors.inspect}") if @errors.count > 0
  end

  def import_wweia_categories()
    @report << ''
    msg = "Start of Importing of WWEIA Categories"
    Rails.logger.debug("*** #{msg}")
    @report << msg
    start_rec_count = LookupTable.all.count
    # read in usda categories into lookup tables:
    filename = Rails.root.join('db','csv_uploads','wweia_food_category.csv')
    chunk_size = 10
    chunk_num = 0
    options = {:chunk_size => chunk_size} # {:key_mapping => {:unwanted_row => nil, :old_row_name => :new_name}}
    n = SmarterCSV.process(filename, options) do |array|
      # we're passing a block in, to process each resulting hash / =row (the block takes array of hashes)
      # when chunking is not enabled, there is only one hash in each array
      # Rails.logger.debug("@@@ read chunk #{array.inspect}")
      array.each_with_index do |row, ix|
        Rails.logger.debug("@@@ read line #{row.inspect}")
        rec_num = chunk_num*chunk_size + ix + 1
        msg = ''
        matching = LookupTable.where(lu_table: 'wweia_cat', lu_code: row[:wweia_food_category])
        if matching.count == 1
          rec = matching.first
          rec.lu_desc = row[:wweia_food_category_description]
          if rec.changed
            rec.save
            if rec.errors.count > 0
              msg = "Error updating WWEIA Category table row:#{rec_num} - #{rec.errors}"
              @errors << err_str
            else
              msg = "Updated row:#{rec_num} - #{rec[:lu_code]}, #{rec[:lu_desc]}"
            end
          else
            # no need to update it, as it has not changed
          end
        else
          rec = LookupTable.new(
            lu_table: 'wweia_cat',
            lu_code: row[:wweia_food_category],
            lu_desc: row[:wweia_food_category_description]
          )
          rec.save
          if rec.errors.count > 0
            msg = "Error writing WWEIA Category table row:#{rec_num} - #{rec.errors}"
            @errors << err_str
          else
            msg = "Added row:#{rec_num} - #{rec[:lu_code]}, #{rec[:lu_desc]}"
          end
        end
        @report << msg
      end
      chunk_num += 1
    end
    diff_num_recs = LookupTable.all.count - start_rec_count
    msg = "# imported #{diff_num_recs} new records from WWEIA Categories"
    Rails.logger.info("***" + msg)
    @report << msg
    Rails.logger.error("ERROR: #{@errors.inspect}") if @errors.count > 0
  end


end
