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
    @report = []
    @errors = []
  end


  # method to do all of the uploads of the usda csv files to initialize the database
  def run()

    # NOTE: all of the uploads should be rerunnable.
    #   check to see if record exists by looking for the record based upon its primary specification fields (primary keys).
    #   If not found, add it, otherwise update all fields except the primary specification fields

    import_csv_into_table('db/csv_uploads/food_category.csv', LookupTable, 'usda_cat', method(:set_food_category_fields) )
    import_csv_into_table('db/csv_uploads/wweia_food_category.csv', LookupTable, 'wweia_cat', method(:set_wweia_category_fields) )



    return @report, @errors
  end

  # method to read any csv import file into any table
  #
  # @param filename is the csv file to be uploaded (including path from rails root)
  # @param model_clazz - the Model that the the fields are to be added/updated
  # @param filter - currently the lookup table's lu_table field value to match
  # @param set_fields is the callback method to properly update the model fields from the csv fields
  # @return - none
  # @example
  #   see run() method for examples
  def import_csv_into_table(filename, model_clazz, filter, set_fields)
    @report << ''
    msg = "Start of Importing of #{model_clazz.class} table"
    Rails.logger.debug("*** #{model_clazz.new.inspect}")
    @report << msg
    start_rec_count = model_clazz.all.count
    # read in usda categories into lookup tables:
    filename = Rails.root.join(filename)
    chunk_size = 10
    chunk_num = 0
    options = { chunk_size: chunk_size } # {:key_mapping => {:unwanted_row => nil, :old_row_name => :new_name}}
    n = SmarterCSV.process(filename, options) do |array|
      array.each_with_index do |row, ix|
        Rails.logger.debug("@@@ read line #{row.inspect}")
        rec_num = chunk_num * chunk_size + ix + 1
        msg = ''
        matching = model_clazz.where(lu_table: filter, lu_code: row[:code])
        if matching.count == 1
          rec = matching.first
          msg, errors = set_fields.call(rec, row)
        else
          rec = LookupTable.new()
          msg, errors = set_fields.call(rec, row)
        end
        Rails.logger.debug("### rec: #{rec.inspect}")
        Rails.logger.debug("### errors: #{errors.inspect}")
        @report << msg
        @errors << errors if errors.present?
      end
      chunk_num += 1
    end
    diff_num_recs = model_clazz.all.count - start_rec_count
    msg = "# imported #{diff_num_recs} new records from #{filename} into #{model_clazz.class}"
    Rails.logger.info("***#{msg}")
    @report << msg
    Rails.logger.error("ERRORs: #{@errors.inspect}") if @errors.count > 0
    # Rails.logger.debug("### @report: #{@report.inspect}")
  end


  # callback method to set the food category entries in the Lookup Table
  #
  # @param rec is the current record in LookupTables
  # @param row is the current row being read from the csv file
  # @return - [ <the message to go in the report>, <the optional error message, or blank> ]
  # @example
  #   see run() method for examples
  def set_food_category_fields(rec, row)
    Rails.logger.debug "*** Food Category Record:"
    Rails.logger.debug "*** rec: #{rec.inspect}"
    Rails.logger.debug "*** row: #{row.inspect}"

    err_str = msg = ""
    # put in fields needed for both update and add
    rec.lu_id = row[:id]
    rec.lu_desc = row[:description]
    # Update the record if it existed already
    if rec.present? && rec.id.present?
      if rec.lu_table != 'usda_cat' || rec.lu_code != row[:code].to_s
        msg = "Error, trying to update an invalid record at Lookup Table id: #{rec.id}"
        Rails.logger.error msg
        Rails.logger.error "### row[:code]: #{row[:code].inspect} rec: #{rec.inspect}"
        err_str = msg
      elsif rec.changed
        rec.save
        msg = "Updated Category Lookup row.id:#{row[:id]} - #{rec[:id]},#{rec[:lu_code]}, #{rec[:lu_desc]}"
      else
        # no need to update it, as it has not changed
      end
    else
      # new record, create it anew
      rec.lu_table = 'usda_cat'
      rec.lu_code = row[:code]
      rec.save
      msg = "added Category Lookup row:#{row[:id]} - #{rec[:id]},#{rec[:lu_code]}, #{rec[:lu_desc]}"
    end
    if rec.errors.count > 0
      msg = "Error writing USDA Category table row:#{row[:id]} - #{rec[:id]} - #{rec.errors.full_messages}"
      err_str = msg
    end
    return msg, err_str
  end


  # callback method to set the wweia food category entries in the Lookup Table
  #
  # @param rec is the current record in LookupTables
  # @param row is the current row being read from the csv file
  # @return - [ <the message to go in the report>, <the optional error message, or blank> ]
  # @example
  #   see run() method for examples
  def set_wweia_category_fields(rec, row)
    Rails.logger.debug "*** WWEIA Food Category Record:"
    Rails.logger.debug "*** rec: #{rec.inspect}"
    Rails.logger.debug "*** row: #{row.inspect}"

    err_str = msg = ""
    # put in fields needed for both update and add
    rec.lu_desc = row[:wweia_food_category_description]
    # Update the record if it existed already
    if rec.present? && rec.id.present?
      if rec.lu_table != 'wweia_cat' || rec.lu_code != row[:code].to_s
        msg = "Error, trying to update an invalid record at Lookup Table id: #{rec.id}"
        Rails.logger.error msg
        Rails.logger.error "### row[:code]: #{row[:code].inspect} rec: #{rec.inspect}"
        err_str = msg
      elsif rec.changed
        rec.save
        msg = "Updated WWEIA Category Lookup row.id:#{row[:id]} - #{rec[:id]},#{rec[:lu_code]}, #{rec[:lu_desc]}"
      else
        # no need to update it, as it has not changed
      end
    else
      # new record, create it anew
      rec.lu_table = 'wweia_cat'
      rec.lu_code = row[:wweia_food_category]
      rec.save
      msg = "added WWEIA Category Lookup row:#{row[:id]} - #{rec[:id]},#{rec[:lu_code]}, #{rec[:lu_desc]}"
    end
    if rec.errors.count > 0
      msg = "Error writing WWEIA Category table row:#{row[:id]} - #{rec[:id]} - #{rec.errors.full_messages}"
      err_str = msg
    end
    return msg, err_str
  end


end
