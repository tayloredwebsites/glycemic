# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

require 'smarter_csv'
class ImportUsdaCsvFiles

  IDENT_MAP_USDA_LU = {
    'clazz' => LookupTable,
    'map' => {
      'lu_table' => 'usda_cat',
      'id' => ':lu_id',
      'code' => ':lu_code',
      'description' => ':lu_desc',
    },
    'ident' => {
      'lu_table' => ':lu_table',
      'lu_code' => ':lu_code'
    },
  }.with_indifferent_access

  IDENT_MAP_WWEIA_LU = {
    'clazz' => LookupTable,
    'map' => {
      'lu_table' => 'wweia_cat',
      'wweia_food_category' => ':lu_code',
      'wweia_food_category_description' => ':lu_desc',
    },
    'ident' => {
      'lu_table' => ':lu_table',
      'lu_code' => ':lu_code'
    },
  }.with_indifferent_access
  
  IDENT_MAP_F_FOOD = {
    'clazz' => Food,
    'map' => {
      'fdc_id' => ':samples_json<fdc_id',
      'data_type' => ':samples_json<fdc_id<data_type',
      'description' => ':name',
      'food_category_id' => ':usda_food_cat_id',
      'publication_date' => ':samples_json<fdc_id<pub_date',
    },
    'ident' => {
      'name' => ':name',
      'fdc_id' => ':samples_json<fdc_id'
    },
  }.with_indifferent_access

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

    import_csv_into_table(
      'db/csv_uploads/food_category.csv',
      LookupTable,
      IDENT_MAP_USDA_LU,
    #   method(:set_food_category_fields)
    )

    import_csv_into_table(
      'db/csv_uploads/wweia_food_category.csv',
      LookupTable,
      IDENT_MAP_WWEIA_LU,
    #   method(:set_wweia_category_fields)
    )

    import_csv_into_table(
      'db/csv_uploads/ff_food.csv',
      Food,
      IDENT_MAP_F_FOOD,
      # method(:set_food_fields)
    )


    return @report, @errors
  end

  # method to read any csv import file into any table
  #
  # @param filename is the csv file to be uploaded (including path from rails root)
  # @param model_clazz - the Model that the the fields are to be added/updated
  # @param ident - hash of: mapping from rec to row; ident to find matching record in database
  # @param set_fields is the callback method to properly update the model fields from the csv fields
  # @return - none
  # @example
  #   see run() method for examples
  def import_csv_into_table(filename, model_clazz, ident_map) #, set_fields_xxx)
    Rails.logger.debug("*********************************************************")
    Rails.logger.debug("IMPORT CSV INTO TABLE")
    Rails.logger.debug("*********************************************************")

    # TODO - remove dynamic set field methods after replacing with new set_fields method
    # load in usda categories if not loading lookup tables
    ident_h = ident_map['ident']
    mapping_h = ident_map['map']
    clazz = ident_map['clazz']
    Rails.logger.debug("&&& clazz: #{clazz.inspect}")
    # load in existing food category mapping if lookup tables have been loaded (previously)
    @usda_cats_by_id = load_usda_cats_by_usda_id() if ident_h[:lu_table].blank?
    # Rails.logger.debug("### @usda_cats_by_id: #{@usda_cats_by_id.inspect}")

    @report << ''
    msg = "Start of Importing of #{model_clazz} table"
    Rails.logger.debug("*** msg: #{msg}")
    Rails.logger.debug("*** record layout: #{model_clazz.new.inspect}")
    @report << msg
    start_rec_count = model_clazz.all.count
    # read in usda categories into lookup tables:
    filename = Rails.root.join(filename)
    chunk_size = 10
    chunk_num = 0
    options = { chunk_size: chunk_size } # {:key_mapping => {:unwanted_row => nil, :old_row_name => :new_name}}
    n = SmarterCSV.process(filename, options) do |array|
      array.each_with_index do |row, ix|
        Rails.logger.debug("@@@ row: #{row.inspect}")
        rec_num = chunk_num * chunk_size + ix + 1
        msg = ''
        errors = []

        # create a row with field names are mapped to the record field names
        #   values in the mapped row will be the actual values from the input row
        mapped_row = map_row(ident_map, row)
        Rails.logger.debug("### mapped_row: #{mapped_row.inspect}")
        
        # create the where string and matching hash to find all matching records (see ident hash)
        ident_hc, ident_where = get_ident_for_row(ident_map, row, mapped_row)
        # Rails.logger.debug("### ident_hc: #{ident_hc.inspect}")
        # Rails.logger.debug("### ident_where: #{ident_where.inspect}")

        # ensure that for has all of the matching fields
        ident_h.each do |fk, fv|
          Rails.logger.debug("%%% checking identifier: #{fk.inspect}, #{fv.inspect}")
          if fv[0] == ':' && fv.split('<').length > 1
            Rails.logger.debug("%%% we have a JSON identifier, skip for database where clause validation")
          else
            if ident_hc[fk].nil? || ident_hc[fk].blank?
              msg = "missing match field for row: #{row.inspect}"
              Rails.logger.debug("%%% #{msg}")
              # errors << msg
            else
              Rails.logger.debug("%%% we have a matching where clause item: #{ident_hc[fk]}")
            end
          end
        end

        errors << "Missing where clause for row: #{mapped_row.inspect}" if ident_hc.length == 0

        if errors.count == 0

          msg, set_errors = save_rec_if_changed(model_clazz, ident_where, ident_hc, mapped_row, mapping_h)
          errors.concat(set_errors)
          # TODO - confirm that this is all records that need to be updated
        else
          msg = "ERROR on save row.fdc_id:#{row.inspect} - #{errors.join('; ')}"
          errors << msg
          Rails.logger.error("Error: #{msg}")
        end
        # Rails.logger.debug("### rec: #{rec.inspect}")
        # Rails.logger.debug("### errors: #{errors.inspect}")
        @report << msg
        @errors.append(errors) if errors.count > 0
      end
      chunk_num += 1
    end
    diff_num_recs = model_clazz.all.count - start_rec_count
    msg = "# imported #{diff_num_recs} new records from #{filename} into #{model_clazz.class}"
    Rails.logger.info("***#{msg}")
    @report << msg
    # Rails.logger.error("ERRORs: #{@errors.inspect}") if @errors.count > 0
    # Rails.logger.debug("### @report: #{@report.inspect}")
  end

  # method to find the matching record in the database, and update it (or create anew)
  #   calls set fields to do the update
  # @return - [ msg, errors_a]
  #   msg: success or failure method to go to report
  #   errors_a: array of error messages to be appended to error report
  def save_rec_if_changed(model_clazz, ident_where, ident_hc, mapped_row, mapping_h)
    # get the matching records from the database
    matching = model_clazz.where(ident_where, ident_hc)

    if matching.count == 1
      # update the existing record
      Rails.logger.debug("@@@ matching #{matching.first.inspect}")
      rec = matching.first
      msg, set_errors = set_fields_and_save(rec, mapped_row, mapping_h)
    else
      # add a new record
      Rails.logger.debug("@@@ no matches")
      rec = model_clazz.new()
      msg, set_errors = set_fields_and_save(rec, mapped_row, mapping_h)
    end
  end

  # method to fill in the record from the mapped row and save to the database
  #
  # @param - rec = new or matched record from the database
  # @param - mapped_row = the input row fields mapped to the database field and new values
  # @param - mapping_h = the mapping hash to convert row field names to database field names
  # @return - [ msg, errors_a]
  #   msg: success or failure method to go to report
  #   errors_a: array of error messages to be appended to error report
  def set_fields_and_save(rec, mapped_row, mapping_h)
    Rails.logger.debug("*********************************************************")
    Rails.logger.debug("SET FIELDS AND SAVE")
    Rails.logger.debug("*********************************************************")

    # TODO - note that the syntax for identifying hash entries has the key followed by <:
    #  make sure to look for duplicate fdc_id keys in the json field, then add key/value
    #  do not allow blank food names

    Rails.logger.debug "*** mapped_row: #{mapped_row.inspect}"

    errors_a = []
    
    # loop through mapped_row and set the fields
    mapped_row.each do |fld, new_val|
      Rails.logger.debug("### updating record value for field: #{fld} with value #{new_val}")
      existing_rec_val = rec.read_attribute(fld)
      if existing_rec_val.present? && existing_rec_val != new_val && mapping_h[fld].present?
          msg = "ERROR: cannot change field to match records with.  #{fld.inspect}: #{mapping_h[fld].inspect}, Row: #{mapped_row.inspect}"
          Rails.logger.error(msg)
          errors_a << msg
      else
        Rails.logger.debug("changing value for #{fld} from #{existing_rec_val} to #{new_val}")
        rec.write_attribute(fld, new_val)
      end
    end
    if errors_a.count == 0
      rec.save 
      if rec.errors.count > 0
        msg = "Error saving mapped_row: #{mapped_row.inspect}, rec_id: #{rec.id}: #{rec.errors.full_messages.join('; ')}"
        Rails.logger.error("ERROR: #{msg}")
        raise "halt"
        errors_a << msg
      else
        Rails.logger.debug "*** updated mapped_row: #{mapped_row.inspect}, rec_id: #{rec.id}"
      end
    end
    return msg, errors_a
  end

  # method to create a hash of the usda food categories in the Lookup table
  #   the hash is keyed by the usda food_category table id
  #   the hash stores the lookup table record for that food category
  #   this can be used to find the Lookup Table id for a food category usda id
  #
  # @return - hash of Lookup Table records for the 'usda_cat' table, keyed by usda id
  def load_usda_cats_by_usda_id()
    cats_by_id = HashWithIndifferentAccess.new()
    LookupTable.where(lu_table: 'usda_cat').all.each do |rec|
      cats_by_id[rec.lu_id] = rec
    end
    return cats_by_id
  end

  # method to set the identity hash with current csv row values and build where clause for matching
  #
  # @param initial ident_h hash from initial call for csv file upload
  # @return - [ <updated ident hash with values from row>, <where clause to get matching records> ]
  def get_ident_for_row(ident_map, row, mapped_row)
    Rails.logger.debug("*********************************************************")
    Rails.logger.debug("GET ident FOR ROW")
    Rails.logger.debug("*********************************************************")
    mapping_h = ident_map['map']
    ident_h = ident_map['ident']
    model_clazz = ident_map['clazz']
    Rails.logger.debug("xxx get_ident_for_row mapping_h #{mapping_h.inspect}")
    Rails.logger.debug("xxx get_ident_for_row ident_h #{ident_h.inspect}")
    Rails.logger.debug("xxx get_ident_for_row mapped_row #{mapped_row.inspect}")
    Rails.logger.debug("xxx get_ident_for_row model_clazz #{model_clazz.inspect}")
    ident_h.each do |fk,fv|
      Rails.logger.debug("### ident_h: fk: #{fk},  #{fv}")
    end
    Rails.logger.debug("xxx get_ident_for_row row #{row.inspect}")
    mapped_ident = HashWithIndifferentAccess.new()

    # build the where clause and fill the ident_h with current row values for finding matching record
    ident_where_a = []
    ident_hc = HashWithIndifferentAccess.new()
    row.each do |k,v|
      # note no append / json fields allowed here.
      Rails.logger.debug("^^^ row - k: #{k.inspect} v: #{v.inspect}")
      # check if row field is mapped, and if so, use the mapped field name for the where clause
      action, to_json_fields_a = get_mapping_type(mapping_h, k)
      Rails.logger.debug("### get_mapping_type - action: #{action.inspect}, to_json_fields_a: #{to_json_fields_a.inspect}")
      Rails.logger.debug("### mapping_h[k]: #{mapping_h[k]}")
      if action == 'set' && mapping_h[k].present?
        Rails.logger.debug("$$$ row for #{k.inspect} is an identifier, and mapped to #{mapping_h[k]}")
        row_field = mapping_h[k] # replace the uploaded field to the mapped database field
        row_field = row_field[1..] if row_field[0] == ':' # ignore any leading : in the mapping definition
      else
        Rails.logger.debug("$$$ row for #{k.inspect} is not a database identifier field")
        row_field = k
      end
      Rails.logger.debug("### ident_h[row_field]: #{ident_h[row_field]}")
      if ident_h[row_field].present?
        if action == 'hash'
          Rails.logger.debug("Is a JSON identifier : do not put in where clause.")
        else
          Rails.logger.debug("Is an identifier : put in where clause. setting #{k.inspect} #{row_field.inspect} to #{v}")
          f_type = get_field_type(model_clazz, row_field)
          case f_type
          when 'integer', :integer
            ident_hc[row_field] = v.to_i
            ident_where_a << "#{row_field} = :#{row_field}"
          when 'string', :string
            ident_hc[row_field] = v.to_s
            ident_where_a << "#{row_field} = :#{row_field}"
          else
            raise "halt missing field type: #{f_type.inspect}"
          end
        end
      else
        Rails.logger.debug("Not Matched : not in ident")
      end
    end
    Rails.logger.debug("$$$ ident_hc: #{ident_hc.inspect}")
    ident_where = ident_where_a.join(' AND ')
    Rails.logger.debug("$$$ ident_where: #{ident_where.inspect}")
    return ident_hc, ident_where # , mapped_row
  end

  # method to parse the mapping hash
  #
  # @param - mapping_h = the mapping hash for this upload
  # @param - k = the record's field
  # @return - [ type of action (constant, set, hash), the mapping split into an array]
  #   action: 'constant' when value is set from the mapping hash
  #   action: 'set' when a single field is set in the database record
  #   action: 'hash' the hash keys for a json field
  #   mv_split: the single value field, or the json field with its hash keys
  def get_mapping_type(mapping_h, k)
    # lookup the mapping for this field
    Rails.logger.debug("### k: #{k}, mapping_h[k]: #{mapping_h[k]}")
    map_v = mapping_h[k]
    if map_v.present?
      # parse out the mapping and return the field(s) to go to
      mv_split = []
      if map_v[0] == ':'
        map_2 = map_v[1..]
        mv_split = map_2.split('<')
      end
      Rails.logger.debug("### mv_split: #{mv_split.inspect}")
      action = {0 => 'constant', 1 => 'set', 2 => 'hash', 3 => 'hash'}[mv_split.length]
    else
      action = 'none'
    end
    return action, mv_split
  end

  # method to map the uploaded row into the fields that will go into the record
  #
  # @param - ident_map = the identifiers and mapping hash for this upload
  # @param - row = the uploaded row=.
  # @return - the mapped row.
  def map_row(ident_map, row)
    Rails.logger.debug("*********************************************************")
    Rails.logger.debug("MAP ROW")
    Rails.logger.debug("*********************************************************")
    Rails.logger.debug "*** row: #{row.inspect}"

    mapped_row = HashWithIndifferentAccess.new()
    
    # loop through mapping and set the fields
    # do not allow ident (matching) fields to be changed.
    ident_map['map'].each do |fld, val|
      Rails.logger.debug("### mapping: #{fld.inspect} => #{val.inspect}")
      action, to_json_fields_a = get_mapping_type(ident_map['map'], fld)
      key = fld
      Rails.logger.debug("map_row for #{key} - has action: #{action.inspect}, to_json_fields_a: #{to_json_fields_a.inspect}")
      case action
      when 'constant'
        Rails.logger.debug("$$$ CONSTANT set field: #{fld} to value #{val}")
        mapped_row[fld] = val
        # rec.write_attribute(to_field, set_field_type(ident_map['clazz'], key, row[fld]))
      when 'set'
        Rails.logger.debug("set field: #{to_json_fields_a[0]} to value #{row[fld.to_sym]}")
        mapped_row[to_json_fields_a[0]] = row[fld.to_sym]
      when 'hash'
        Rails.logger.debug("add to json/hash field: #{key} to #{row[fld.to_sym]}")
        # mapped_row[key] = row[fld]
        field_with_json = to_json_fields_a[0]
        Rails.logger.debug("### field_with_json: #{field_with_json.inspect}")
        mapped_row[field_with_json] = HashWithIndifferentAccess.new() if mapped_row[field_with_json].nil?
        Rails.logger.debug("### mapped_row for field_with_json - #{field_with_json} = #{mapped_row[field_with_json]}")
        json_item_key1 = to_json_fields_a[1]
        Rails.logger.debug("### json_item_key1.to_sym: #{ json_item_key1.to_sym }")
        mapped_json_item_key1 = row[json_item_key1.to_sym]
        Rails.logger.debug("### mapped_json_item_key1: #{ mapped_json_item_key1.inspect }")
        Rails.logger.debug("map mapped_row[mapped_json_item_key1]: #{mapped_row[field_with_json][mapped_json_item_key1].inspect}")
        if mapped_row[field_with_json][mapped_json_item_key1].nil?
          mapped_row[field_with_json][mapped_json_item_key1] = HashWithIndifferentAccess.new()
          Rails.logger.debug("### mapped_row  for field_with_json - #{field_with_json} = #{mapped_row[field_with_json]}")
        end
        if to_json_fields_a.length == 2
          Rails.logger.debug("to add to json field: #{field_with_json} [ #{mapped_json_item_key1} ] with value #{row[fld.to_sym]}")
          mapped_row[field_with_json][mapped_json_item_key1][json_item_key1] = row[fld.to_sym]
        else
          json_item_key2 = to_json_fields_a[2]
          Rails.logger.debug("### json_item_key2: #{ json_item_key2.inspect }")
          Rails.logger.debug("to add to json field: #{field_with_json} [ #{mapped_json_item_key1} ] with value #{row[fld.to_sym]}")
          mapped_row[field_with_json][mapped_json_item_key1][json_item_key2] = row[fld.to_sym]
        end
      when 'none'
        # skip this input field
      end
    end
    Rails.logger.debug("### mapped_row: #{mapped_row.inspect}")
    return mapped_row
  end

  # method to set a value as string or integer based upon its field type in the record
  #
  # @param - model_clazz = class of the model record (ready to act act as a class variable)
  # @param - field_name = the field to get the field type from
  # @param - value = the value that is intended to be written to that record field.
  # @return - the value as a string or integer, as appropriate for the record field.
  def set_field_type(model_clazz, field_name, value)
    ret_val = ''
    case model_clazz.column_for_attribute(field_name).type
    when :integer
      ret_val = value.to_i if value.is_a? String
      ret_val = value if value.is_a? Integer      
    when :string
      ret_val = value if value.is_a? String
      ret_val = value.to_s if value.is_a? Integer
    else
      Rails.logger.error("$$$ field: #{field_name} is not matched, of type #{value.class}, with value: #{value.inspect}")
    end
    return ret_val
  end

  # method to get the field type in the record
  #
  # @param - model_clazz = class of the model record (ready to act act as a class variable)
  # @param - field_name = the field to get the field type from
  # @return - the type.
  def get_field_type(model_clazz, field_name)
    ret_val = ''
    return model_clazz.column_for_attribute(field_name).type
  end

end
