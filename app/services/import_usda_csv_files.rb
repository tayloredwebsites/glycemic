# Diet Support Program
# Copyright (C) 2023 David A. Taylor of Taylored Web Sites (tayloredwebsites.com)
# Licensed under AGPL-3.0-only.  See https://opensource.org/license/agpl-v3/

require 'smarter_csv'

# code for importing USDA CSF files
# how to call this code:
# report, errors, debug, audit = ImportUsdaCsvFiles.perform(report_num, deb_arg)
class ImportUsdaCsvFiles

  REGEX_BETWEEN_BRACKETS = /\[(.*?)\]/m
  REGEX_BEFORE_BRACKETS = /(.*)\[/m
  REGEX_AFTER_BRACKETS = /\](.*)/m
  REGEX_BETWEEN_PAREN = /\((.*?)\)/m
  REGEX_BEFORE_PAREN = /(.*)\(/m
  REGEX_AFTER_PAREN = /\)(.*)/m

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
      'lu_code' => ':lu_code',
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
      'lu_code' => ':lu_code',
    },
  }.with_indifferent_access

  IDENT_MAP_NUTRIENT = {
    'clazz' => Nutrient,
    'map' => {
      'id' => ':usda_nutrient_id',
      'name' => ':name',
      'unit_name' => ':unit_code',
      'nutrient_nbr' => ':usda_nutrient_num',
    },
    'ident' => {
      'name' => ':name',
      'usda_nutrient_id' => ':usda_nutrient_id',
    },
  }.with_indifferent_access

  # initial load of usda foundation food items into a separate USDA file
  # - with all in by their fdc_id, allowing duplicate names
  # upload file layout
  # "fdc_id","data_type","description","food_category_id","publication_date"
  # "319874","sample_food","HUMMUS, SABRA CLASSIC","16","2019-04-01"
  IDENT_MAP_USDA_FOOD = {
    'clazz' => UsdaFood,
    'map' => {
      'fdc_id' => ':fdc_id',
      'data_type' => ':usda_data_type',
      'description' => ':name',
      'food_category_id' => ':usda_food_cat_id',
    },
    'ident' => {
      'fdc_id' => ':fdc_id', # records are unique by fdc_id, so this allows reruns
      'usda_data_type' => ':usda_data_type', # hopefully these are not identifiers, but just in case
    }, 
  }.with_indifferent_access
  
  # initial load of usda foundation food nutrient items into a separate USDA file
  # 

  # "id","fdc_id","nutrient_id","amount","data_points","derivation_id","min","max","median","footnote","min_year_acqured"
  # "2201847","319877","1051","56.3","1","1","","","","",""

  # t.integer "fdc_id", null: false
  # t.integer "nutrient_id", null: false
  # t.integer "usda_nutrient_id"
  # t.integer "usda_nutrient_num"
  # t.float "amount"
  # t.integer "data_points"
  # t.boolean "active", default: true

  IDENT_MAP_USDA_FOOD_NUTRIENT = {
    'clazz' => UsdaFoodNutrient,
    'map' => {
      'fdc_id' => ':fdc_id',
      'nutrient_id' => ':usda_nutrient_id',
      'amount' => ':amount',
      'data_points' => ':data_points',
    },
    'ident' => {
      'fdc_id' => ':fdc_id',
      'nutrient_id' => ':usda_nutrient_id',
    },
  }.with_indifferent_access

  def initialize()
    @report = []
    @errors = []
    @debug = []
    @audit = []
    @food_rec_count = Food.all.count
    log_debug("Food Records at start: #@food_rec_count")
  end

  def self.perform(step_num, debug_mode=false)
    # debug mode (print out debugging statements) only if passed in as true
    @debug_mode = (debug_mode == false) ? false : (debug_mode == true) ? true : false
    serv_obj = self.new()
    serv_obj.run(step_num)
  end

  # method to do all of the uploads of the usda csv files to initialize the database
  def run(step_num)

    log_debug("debug mode: #{@debug_mode}")
    # NOTE: all of the uploads should be rerunnable.
    #   check to see if record exists by looking for the record based upon its primary specification fields (primary keys).
    #   If not found, add it, otherwise update all fields except the primary specification fields
    case step_num
    when 1
      import_csv_into_table(
        'db/csv_uploads/food_category.csv',
        LookupTable,
        IDENT_MAP_USDA_LU,
      )
      import_csv_into_table(
        'db/csv_uploads/wweia_food_category.csv',
        LookupTable,
        IDENT_MAP_WWEIA_LU,
      )
      import_csv_into_table(
        'db/csv_uploads/nutrient.csv',
        Nutrient,
        IDENT_MAP_NUTRIENT,
      )
    when 2
      fix_dup_nutrition_records()
    when 3
      import_csv_into_table(
        'db/csv_uploads/ff_food.csv',
        UsdaFood,
        IDENT_MAP_USDA_FOOD,
      )
    when 4
      import_csv_into_table(
        'db/csv_uploads/ff_food_nutrient.csv',
        UsdaFoodNutrient,
        IDENT_MAP_USDA_FOOD_NUTRIENT,
      )
    when 5
      load_foods_from_usda()
    when 6
      deact_empty_foods()
    when 7
      update_nutrient_unit_codes()
    else
      raise "invalid step number"
    end
    return @report, @errors, @debug, @audit
  end

  # method to read any csv import file into any table
  #
  # @param filename is the csv file to be uploaded (including path from rails root)
  # @param model_clazz - the Model that the the fields are to be added/updated
  # @param ident - hash of: mapping from rec to row; ident to find matching record in database
  # deprecated @param set_fields is the callback method to properly update the model fields from the csv fields
  # @return - none
  # @example
  #   see run() method for examples
  def import_csv_into_table(filename, model_clazz, ident_map) #, set_fields_xxx)
    log_debug("*********************************************************")
    log_debug("IMPORT CSV INTO TABLE")
    log_debug("*********************************************************")

    # TODO - remove dynamic set field methods after replacing with new set_fields method
    # load in usda categories if not loading lookup tables
    ident_h = ident_map['ident']
    mapping_h = ident_map['map']
    clazz = ident_map['clazz']
    log_debug("&&& clazz: #{clazz.inspect}")
    # load in existing food category mapping if lookup tables have been loaded (previously)
    @usda_cats_by_id = load_usda_cats_by_usda_id() if ident_h[:lu_table].blank?
    # log_debug("### @usda_cats_by_id: #{@usda_cats_by_id.inspect}")

    @report << '*** updated mapped_row:'
    msg = "Start of Importing of #{model_clazz} table"
    log_debug("*** msg: #{msg}")
    log_debug("*** record layout: #{model_clazz.new.inspect}")
    @report << msg
    start_rec_count = model_clazz.all.count
    # read in usda categories into lookup tables:
    filename = Rails.root.join(filename)
    chunk_size = 10
    chunk_num = 0
    options = { chunk_size: chunk_size } # {:key_mapping => {:unwanted_row => nil, :old_row_name => :new_name}}
    n = SmarterCSV.process(filename, options) do |array|
      array.each_with_index do |row, ix|
        log_debug("@@@ row: #{row.inspect}")
        rec_num = chunk_num * chunk_size + ix + 1
        msg = ''
        errors = []

        # create a row with field names are mapped to the record field names
        #   values in the mapped row will be the actual values from the input row
        mapped_row = map_row(ident_map, row)
        log_debug("### mapped_row: #{mapped_row.inspect}")
        
        # create the where string and matching hash to find all matching records (see ident hash)
        ident_hc, ident_where = get_ident_for_row(ident_map, row, mapped_row)
        # log_debug("### ident_hc: #{ident_hc.inspect}")
        # log_debug("### ident_where: #{ident_where.inspect}")

        # ensure that for has all of the matching fields
        ident_h.each do |fk, fv|
          log_debug("%%% checking identifier: #{fk.inspect}, #{fv.inspect}")
          if fv[0] == ':' && fv.split('<').length > 1
            log_debug("%%% we have a JSON identifier, skip for database where clause validation")
          else
            if ident_hc[fk].nil? || ident_hc[fk].blank?
              msg = "missing match field for row: #{row.inspect}"
              log_debug("%%% #{msg}")
              # errors << msg
            else
              log_debug("%%% we have a matching where clause item: #{ident_hc[fk]}")
            end
          end
        end

        # allow no matching (all records are added)
        # errors << "Missing where clause for row: #{mapped_row.inspect}" if ident_hc.length == 0
        # # TODO: do not allow adding blank foods or usda_foods
        # errors << "blank name for row: #{row}" if mapped_row[:name].blank?

        if errors.count == 0

          msg, set_errors = save_rec_if_changed(model_clazz, ident_where, ident_hc, mapped_row, mapping_h)
          errors.concat(set_errors) if set_errors.present? && set_errors.count > 0
          # TODO - confirm that this is all records that need to be updated
        else
          msg = "ERROR on save: row - errors:#{row.inspect} - #{errors.join('; ')}"
          errors << msg
          Rails.logger.error("Error: #{msg}")
        end
        log_debug("###### msg: #{msg.inspect}")
        # log_debug("### errors: #{errors.inspect}")
        @report << msg if msg.present?
        @errors.concat(errors) if errors.present? && errors.count > 0
      end
      # raise "halt after first block of record for debugging"
      chunk_num += 1
    end
    diff_num_recs = model_clazz.all.count - start_rec_count
    msg = "# imported #{diff_num_recs} new records from #{filename} into #{model_clazz.class}"
    Rails.logger.info("***#{msg}")
    @report << msg
    # Rails.logger.error("ERRORs: #{@errors.inspect}") if @errors.count > 0
    # log_debug("### @report: #{@report.inspect}")
  end

  # method to find the matching record in the database, and update it (or create anew)
  #   calls set fields to do the update
  # @return - [ msg, errors_a]
  #   msg: success or failure method to go to report
  #   errors_a: array of error messages to be appended to error report
  def save_rec_if_changed(model_clazz, ident_where, ident_hc, mapped_row, mapping_h)
    # get the matching records from the database
    # if no matching criterion, do not look up matching, and always add
    if ident_hc.length == 0
      matching = []
    else
      matching = model_clazz.where(ident_where, ident_hc)
    end

    if matching.count == 1
      # update the existing record
      log_debug("@@@ matching #{matching.first.inspect}")
      rec = matching.first
      msg, set_errors = set_fields_and_save(rec, mapped_row, mapping_h)
    else
      # add a new record
      log_debug("@@@ no matches")
      rec = model_clazz.new()
      msg, set_errors = set_fields_and_save(rec, mapped_row, mapping_h)
    end
    # @report << msg
    # @errors.append(set_errors) if set_errors.present? && set_errors.count > 0
    return msg, set_errors
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
    log_debug("*********************************************************")
    log_debug("SET FIELDS AND SAVE")
    log_debug("*********************************************************")

    # TODO - note that the syntax for identifying hash entries has the key followed by <:
    #  make sure to look for duplicate fdc_id keys in the json field, then add key/value
    #  do not allow blank food names

    log_debug "*** mapped_row: #{mapped_row.inspect}"

    errors_a = []
    
    # loop through mapped_row and set the fields
    mapped_row.each do |fld, new_val|
      log_debug("### updating record value for field: #{fld} with value #{new_val}")
      existing_rec_val = rec.read_attribute(fld)
      if existing_rec_val.present? && existing_rec_val != new_val && mapping_h[fld].present?
          msg = "ERROR: cannot change field to match records with.  #{fld.inspect}: #{mapping_h[fld].inspect}, Row: #{mapped_row.inspect}"
          Rails.logger.error(msg)
          errors_a << msg
      else
        log_debug("changing value for #{fld} from #{existing_rec_val} to #{new_val}")
        rec.write_attribute(fld, new_val)
      end
    end
    # check if record is valid before saving
    if errors_a.count == 0 && rec.invalid?
      msg = "Invalid mapped_row: #{mapped_row.inspect}, rec_id: #{rec.id}: #{rec.errors.full_messages.join('; ')}, #{rec.inspect}"
      Rails.logger.error(msg)
      errors_a << msg
    end
    if errors_a.count == 0 && rec.changed?
      rec.save 
      if rec.errors.count > 0
        msg = "Error saving mapped_row: #{mapped_row.inspect}, rec_id: #{rec.id}: #{rec.errors.full_messages.join('; ')}, #{rec.inspect}"
        Rails.logger.error("ERROR: #{msg}")
        raise "halt"
        errors_a << msg
      else
        msg = "*** updated mapped_row: #{mapped_row.inspect}, rec_id: #{rec.id}"
        log_debug msg
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
    log_debug("*********************************************************")
    log_debug("GET ident FOR ROW")
    log_debug("*********************************************************")
    mapping_h = ident_map['map']
    ident_h = ident_map['ident']
    model_clazz = ident_map['clazz']
    log_debug("xxx get_ident_for_row mapping_h #{mapping_h.inspect}")
    log_debug("xxx get_ident_for_row ident_h #{ident_h.inspect}")
    log_debug("xxx get_ident_for_row mapped_row #{mapped_row.inspect}")
    log_debug("xxx get_ident_for_row model_clazz #{model_clazz.inspect}")
    ident_h.each do |fk,fv|
      log_debug("### ident_h: fk: #{fk},  #{fv}")
    end
    log_debug("xxx get_ident_for_row row #{row.inspect}")
    mapped_ident = HashWithIndifferentAccess.new()

    # build the where clause and fill the ident_h with current row values for finding matching record
    ident_where_a = []
    ident_hc = HashWithIndifferentAccess.new()
    # loop through record fields
    row.each do |k,v|
      # note no append / json fields allowed here.
      log_debug("^^^ row - k: #{k.inspect} v: #{v.inspect}")
      # check if row field is mapped, and if so, use the mapped field name for the where clause
      action, to_json_fields_a = get_mapping_type(mapping_h, k, row)
      log_debug("### get_mapping_type - action: #{action.inspect}, to_json_fields_a: #{to_json_fields_a.inspect}")
      log_debug("### mapping_h[k]: #{mapping_h[k]}")
      if action == 'set' && mapping_h[k].present?
        log_debug("$$$ row for #{k.inspect} is #{ident_h[k].blank? ? "not" : ''} an identifier (#{ident_h[k]}), and mapped to #{mapping_h[k]}")
        row_field = mapping_h[k] # replace the uploaded field to the mapped database field
        row_field = row_field[1..] if row_field[0] == ':' # ignore any leading : in the mapping definition
      else
        log_debug("$$$ row for #{k.inspect} is not a database identifier field")
        row_field = k
      end
      log_debug("### ident_h[row_field]: #{ident_h[row_field]}")
      log_debug("### ident_h[k]: #{ident_h[k]}")
      if ident_h[k].present?
        if action == 'hash'
          log_debug("Is a JSON identifier : do not put in where clause.")
        else
          log_debug("Is an identifier : put in where clause. setting #{k.inspect} #{row_field.inspect} to #{v}")
          f_type = get_field_type(model_clazz, row_field)
          case f_type
          when 'integer', :integer
            ident_hc[k] = v.to_i
            ident_where_a << "#{row_field} = :#{k}"
          when 'string', :string
            ident_hc[k] = v.to_s
            ident_where_a << "#{row_field} = :#{k}"
          else
            raise "halt missing field type: #{f_type.inspect}"
          end
          log_debug("### updated ident_hc: #{ident_hc.inspect}")
          log_debug("### updated ident_where: #{ident_where_a.inspect}")
        end
      else
        log_debug("Not Matched : not in ident")
      end
    end
    log_debug("$$$ ident_hc: #{ident_hc.inspect}")
    ident_where = ident_where_a.join(' AND ')
    log_debug("$$$ ident_where: #{ident_where.inspect}")
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
  def get_mapping_type(mapping_h, k, row)
    # lookup the mapping for this field
    log_debug("### k: #{k}, mapping_h[k]: #{mapping_h[k]}")
    map_v = mapping_h[k]
    if !map_v.nil?
      # parse out the mapping and return the field(s) to go to
      mv_split = []
      if map_v[0] == ':'
        map_2 = map_v[1..]
        mv_split = map_2.split('<')
      end
      log_debug("### mv_split: #{mv_split.inspect}")
      action = {0 => 'constant', 1 => 'set', 2 => 'hash', 3 => 'hash'}[mv_split.length]
    else
      action = 'none'
    end
    return action, mv_split
  end


  # # method to obtain all mappings for an input row field using the mapping hash
  # #
  # # @param - mapping_h = the mapping hash for this upload
  # # @param - rf = the field from the uploaded row
  # # @param - row = the uploaded row for finding values for the mapping
  # # @return - none - updates the @mapped_row instance variable
  # #    with the mappings for this input row field
  # def set_maps_for_row_field(mapping_h, rf, row)
  #   # lookup the mappings for this field
  #   log_debug("### rf: #{rf}, mapping_h[rf]: #{mapping_h[rf]}")
  #   map_v = mapping_h[rf]
  #   rf_mappings = []
  #   if map_v.present?
  #     # parse out the mapping and return the field(s) to go to
  #     if map_v.is_a?(Array)
  #       log_debug("### Mapping is an array")
  #       rf_mappings = map_v
  #     else
  #       rf_mappings = [ map_v ]
  #     end
  #     # loop through the mappings for this field
  #     rf_mappings.each do |a_map|
  #       mv_split = []
  #       if map_v[0] == ':'
  #         map_2 = map_v[1..]
  #         lookup_field_name = map_2[REGEX_BETWEEN_BRACKETS, 1]
  #         if lookup_field_name.present?
  #           # we have a field lookup for a value in another table
  #           # we need to get the model class name before the brackets
  #           lookup_clazz = map_2[REGEX_BEFORE_BRACKETS, 1].camelize #.constantize
  #           # we need to set the looked up value into this field
  #           after_brackets = map_2[REGEX_AFTER_BRACKETS, 1]
  #           if after_brackets[0..1] == '>:' && after_brackets.length > 2
  #             # we have the set field name after these characters
  #             lookup_field_a = lookup_field_name.split('=')
  #             if lookup_field_a.size == 2
  #               set_field_name = lookup_field_a[0]
  #               set_field_match = lookup_field_a[1]
  #               set_field_match_val = row[set_field_match.to_sym]
  #             else
  #               raise "invalid arguments for field name in mapping: #{map_2.inspect}, #{after_brackets_a.inspect}"
  #             end
  #           else
  #             raise "invalid field name in mapping: #{map_2.inspect}, #{afer_brackets.inspect}"
  #           end
  #           log_debug("### set_maps... set_field_name: #{set_field_name.inspect} = lookup_clazz: #{lookup_clazz.inspect}, lookup_field_name: #{set_field_name} =  #{set_field_match_val}")
  #           # Lookup the value in the table
  #           recs = lookup_clazz.constantize.where("#{set_field_name} = ?", set_field_match_val)
  #           if recs.size == 1
  #             # we matched the lookup field exactly, lets use it
  #             rec = recs.first
  #             log_debug("### matched lookup exactly: rec.id: #{rec.id} to go in field #{set_field_name}")
  #             @mapped_row[set_field_name] = rec.id
  #           else
  #             raise "cannot find match for lookup #{recs.size}"
  #           end
  #           @mapped_row.inspect
  #         else
  #           # we have a mapping to a field in this table
  #           mv_split = map_2.split('<')
  #           # # get_ident_for_row functionality for single field set
  #           # log_debug("$$$ row for #{k.inspect} is an identifier, and mapped to #{mapping_h[k]}")
  #           # row_field = mapping_h[k] # replace the uploaded field to the mapped database field
  #           # row_field = row_field[1..] if row_field[0] == ':' # ignore any leading : in the mapping definition

  #           # # map_row functionality for single field set
  #           # log_debug("set field: #{to_json_fields_a[0]} to value #{row[fld.to_sym]}")
  #           # mapped_row[to_json_fields_a[0]] = row[fld.to_sym]
     
  #           # # get_ident_for_row functionality for hash
  #           # log_debug("Is an identifier : put in where clause. setting #{k.inspect} #{row_field.inspect} to #{v}")
  #           # f_type = get_field_type(model_clazz, row_field)
  #           # case f_type
  #           # when 'integer', :integer
  #           #   ident_hc[row_field] = v.to_i
  #           #   ident_where_a << "#{row_field} = :#{row_field}"
  #           # when 'string', :string
  #           #   ident_hc[row_field] = v.to_s
  #           #   ident_where_a << "#{row_field} = :#{row_field}"
  #           # else
  #           #   raise "halt missing field type: #{f_type.inspect}"
  #           # end
  
  #           # # map_row functionality for hash
  #           # log_debug("add to json/hash field: #{key} to #{row[fld.to_sym]}")
  #           # # mapped_row[key] = row[fld]
  #           # field_with_json = to_json_fields_a[0]
  #           # log_debug("### field_with_json: #{field_with_json.inspect}")
  #           # mapped_row[field_with_json] = HashWithIndifferentAccess.new() if mapped_row[field_with_json].nil?
  #           # log_debug("### mapped_row for field_with_json - #{field_with_json} = #{mapped_row[field_with_json]}")
  #           # json_item_key1 = to_json_fields_a[1]
  #           # log_debug("### json_item_key1.to_sym: #{ json_item_key1.to_sym }")
  #           # mapped_json_item_key1 = row[json_item_key1.to_sym]
  #           # log_debug("### mapped_json_item_key1: #{ mapped_json_item_key1.inspect }")
  #           # log_debug("map mapped_row[mapped_json_item_key1]: #{mapped_row[field_with_json][mapped_json_item_key1].inspect}")
  #           # if mapped_row[field_with_json][mapped_json_item_key1].nil?
  #           #   mapped_row[field_with_json][mapped_json_item_key1] = HashWithIndifferentAccess.new()
  #           #   log_debug("### mapped_row  for field_with_json - #{field_with_json} = #{mapped_row[field_with_json]}")
  #           # end
  #           # if to_json_fields_a.length == 2
  #           #   log_debug("to add to json field: #{field_with_json} [ #{mapped_json_item_key1} ] with value #{row[fld.to_sym]}")
  #           #   mapped_row[field_with_json][mapped_json_item_key1][json_item_key1] = row[fld.to_sym]
  #           # else
  #           #   json_item_key2 = to_json_fields_a[2]
  #           #   log_debug("### json_item_key2: #{ json_item_key2.inspect }")
  #           #   log_debug("to add to json field: #{field_with_json} [ #{mapped_json_item_key1} ] with value #{row[fld.to_sym]}")
  #           #   mapped_row[field_with_json][mapped_json_item_key1][json_item_key2] = row[fld.to_sym]
  #           # end
    
  #         end
  #       else
  #         # check if we have text between parenthesis
  #         in_paren = map_2[REGEX_BETWEEN_PAREN, 1]
  #         if in_paren.present?
  #           # custom coded functionality
  #           log_debug("### in parenthesis: #{in_paren.inspect}")
  #           case map_2[REGEX_BEFORE_PAREN, 1]
  #           when 'variance'
  #             # get the field names for the mean, variance, and json array of values
  #             field_a = map_2[REGEX_BETWEEN_PAREN, 1]
  #           else
  #             raise 'invalid functionality in mapping'
  #           end
  #         else
  #           # otherwise we have a constant
  #           # log_debug("$$$ row for #{k.inspect} is not a database identifier field")
  #           # row_field = k

  #           # # map_row functionality
  #           # log_debug("$$$ CONSTANT set field: #{fld} to value #{val}")
  #           # mapped_row[fld] = val
  #           # # rec.write_attribute(to_field, set_field_type(ident_map['clazz'], key, row[fld]))
  #         end
  #       end
  #       log_debug("### mv_split: #{mv_split.inspect}")
  #       raise "we need to finish mapping code"
  #       action = {0 => 'constant', 1 => 'set', 2 => 'hash', 3 => 'hash'}[mv_split.length]
  #     end
  #   else
  #     action = 'none'
  #   end
  #   raise 'Stopping after first set_maps_for_row_field'
  # end


  # method to map the uploaded row into the fields that will go into the record
  #
  # @param - ident_map = the identifiers and mapping hash for this upload
  # @param - row = the uploaded row=.
  # @return - the mapped row.
  def map_row(ident_map, row)
    log_debug("*********************************************************")
    log_debug("MAP ROW")
    log_debug("*********************************************************")
    log_debug "*** row: #{row.inspect}"

    @mapped_row = mapped_row = HashWithIndifferentAccess.new()
    
    # loop through mapping and set the fields
    # do not allow ident (matching) fields to be changed.
    ident_map['map'].each do |fld, val|
      log_debug("### mapping: #{fld.inspect} => #{val.inspect}")
      action, to_json_fields_a = get_mapping_type(ident_map['map'], fld, row)
      key = fld
      log_debug("map_row for #{key} - has action: #{action.inspect}, to_json_fields_a: #{to_json_fields_a.inspect}")
      case action
      when 'constant'
        log_debug("$$$ CONSTANT set field: #{fld} to value #{val}")
        mapped_row[fld] = val
        # rec.write_attribute(to_field, set_field_type(ident_map['clazz'], key, row[fld]))
      when 'set'
        log_debug("set field: #{to_json_fields_a[0]} to value #{row[fld.to_sym]}")
        mapped_row[to_json_fields_a[0]] = row[fld.to_sym]
      when 'hash'
        log_debug("add to json/hash field: #{key} to #{row[fld.to_sym]}")
        # mapped_row[key] = row[fld]
        field_with_json = to_json_fields_a[0]
        log_debug("### field_with_json: #{field_with_json.inspect}")
        mapped_row[field_with_json] = HashWithIndifferentAccess.new() if mapped_row[field_with_json].nil?
        log_debug("### mapped_row for field_with_json - #{field_with_json} = #{mapped_row[field_with_json]}")
        json_item_key1 = to_json_fields_a[1]
        log_debug("### json_item_key1.to_sym: #{ json_item_key1.to_sym }")
        mapped_json_item_key1 = row[json_item_key1.to_sym]
        log_debug("### mapped_json_item_key1: #{ mapped_json_item_key1.inspect }")
        log_debug("map mapped_row[mapped_json_item_key1]: #{mapped_row[field_with_json][mapped_json_item_key1].inspect}")
        if mapped_row[field_with_json][mapped_json_item_key1].nil?
          mapped_row[field_with_json][mapped_json_item_key1] = HashWithIndifferentAccess.new()
          log_debug("### mapped_row  for field_with_json - #{field_with_json} = #{mapped_row[field_with_json]}")
        end
        if to_json_fields_a.length == 2
          log_debug("to add to json field: #{field_with_json} [ #{mapped_json_item_key1} ] with value #{row[fld.to_sym]}")
          mapped_row[field_with_json][mapped_json_item_key1][json_item_key1] = row[fld.to_sym]
        else
          json_item_key2 = to_json_fields_a[2]
          log_debug("### json_item_key2: #{ json_item_key2.inspect }")
          log_debug("to add to json field: #{field_with_json} [ #{mapped_json_item_key1} ] with value #{row[fld.to_sym]}")
          mapped_row[field_with_json][mapped_json_item_key1][json_item_key2] = row[fld.to_sym]
        end
      when 'none'
        # skip this input field
      end
    end
    log_debug("### mapped_row: #{mapped_row.inspect}")
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

  def fix_dup_nutrition_records()
    Rails.logger.info("*********************************************************")
    Rails.logger.info("FIX DUPLICATE NUTRITION RECORDS")
    Rails.logger.info("*********************************************************")

    @report << "FIX DUPLICATE NUTRITION RECORDS"

    log_debug "point duplicate nutrient records to single active one"
    log_debug "see dups in console using 'Nutrient.select(:name, :unit_code).group_by(&:name)'"
    n1a = Nutrient.find_by(name: "Oligosaccharides", unit_code: 'MG')
    if n1a.present?
      n1b = Nutrient.find_by(name: "Oligosaccharides", unit_code: 'G')
      if n1b.present?
        log_debug "setting G Oligosaccharides record id: #{n1b.id} to point to  #{n1a.id}"
        n1b.active = false
        n1b.use_this_id = n1a.id
        n1b.save
      else
        # raise "Missing G Oligosaccharides record"
        Rails.logger.error("Missing G Oligosaccharides record")
      end
    else
      raise "Missing MG Oligosaccharides record"
    end

    n2a = Nutrient.find_by(name: "Energy", unit_code: 'kJ')
    if n2a.present?
      n2b = Nutrient.find_by(name: "Energy", unit_code: 'KCAL')
      if n2b.present?
        log_debug "setting KCAL Energy record id: #{n2b.id} to point to  #{n2a.id}"
        n2b.active = false
        n2b.use_this_id = n2a.id
        n2b.save
      else
        # raise "Missing KCAL Energy record"
        Rails.logger.error "Missing KCAL Energy record"
      end
    else
      raise "Missing kJ Energy record"
    end
  end

  def load_foods_from_usda
    Rails.logger.info("*********************************************************")
    Rails.logger.info("LOAD FOODS FROM USDA")
    Rails.logger.info("*********************************************************")
      
    # coding this to be rerunnable (no transactions)

    # load in existing food category mapping
    @usda_cats_by_id = load_usda_cats_by_usda_id()
    # log_debug("### @usda_cats_by_id: #{@usda_cats_by_id.inspect}")

    @report << "LOAD FOODS FROM USDA"
    # msg = "Start of Importing of #{model_clazz} table"
    # log_debug("*** msg: #{msg}")
    # log_debug("*** record layout: #{model_clazz.new.inspect}")
    # @report << msg

    exit_msg = ''

    # Loop through all UsdaFood records (to properly put it in a Food record)
    UsdaFood.all.each do |uf|
      log_debug("**************")
      log_debug("*** New UsdaFood record: #{uf.inspect}")
      break if exit_msg.present?
      reset_error_flag()
      log_error("ERROR: missing fdc_id in UsdaFood: #{uf.inspect}") if uf.fdc_id.blank?
      log_error("ERROR: Blank food name in UsdaFood: #{uf.inspect}") if uf.name.blank?

      # get or create the matching food record into f variable
      save_food_rec = false
      if !error_flagged?()
        matching_recs = Food.where(name: uf.name)
        if matching_recs.count == 0
          f = Food.new
          f.name = uf.name
          f.usda_fdc_ids_json = []
          save_food_rec = true
          log_audit("Adding a new food record for #{f.name}")
        elsif matching_recs.count == 1
          f = matching_recs.first
          log_error("ERROR: mismatched name food.name: #{f.name} != usda_food.name: #{uf.name}") if f.name != uf.name
        else
          f = matching_recs.first
          log_error("SYSTEM ERROR: duplicate food name found in foods table usda_food.name: #{uf.name}, count: #{matching_recs.count}")
        end
        log_debug("### Found Food record: #{f.inspect}")
        # check matching food category, or set it if new
        if f.usda_food_cat_id.blank?
          f.usda_food_cat_id = uf.usda_food_cat_id
          save_food_rec = true
        elsif f.usda_food_cat_id != uf.usda_food_cat_id
          if (f.usda_food_cat_id == 9 && uf.usda_food_cat_id == 11) ||
            (f.usda_food_cat_id == 11 && uf.usda_food_cat_id == 9)
            # food is saved as both 9 - "Fruits and Fruit Juices" and as 11 - "Vegetables and Vegetable Products"
            # set food record as 11 "Vegetables and Vegetable Products"
            f.usda_food_cat_id = 11
            save_food_rec = true
          elsif f.usda_food_cat_id.present? && uf.usda_food_cat_id.blank?
            # Usda Food record is missing category, use the existing food record category
          else
            log_error("ERROR: Mismatching food category id.  Food rec #{f.id} has #{f.usda_food_cat_id}, UsdaFood rec #{uf.id} has #{uf.usda_food_cat_id}")
          end
        end
        # TODO: set food record's wweia_food_cat_id when needed
      end

      # update the food record's fdc_id json field
      if !error_flagged?()
        log_debug("### Food Record fdc json: #{f.usda_fdc_ids_json.inspect}")
        if !f.usda_fdc_ids_json.include?(uf.fdc_id.to_s)
          # food record already contains the fdic in the fdic json field
          f.usda_fdc_ids_json << uf.fdc_id.to_s
          log_debug("### Updated Food Record fdc json: #{f.usda_fdc_ids_json.inspect}")
        end
        if save_food_rec == true
          f.save
          log_error("ERROR: Saving Food rec errors: #{f.errors.full_messages.join('; ')}") if f.errors.count > 0
          f.reload()
          log_debug("### Updated Food record: #{f.inspect}")
          log_audit("Add/update a food record for #{f.name}")
        end
      end

      # add or update FoodNutrient records from UsdaFoodNutrient records
      save_food_nut_rec = false
      if !error_flagged?() # && exit_msg.blank?
        log_debug("### no error saving food record")
        # Get all of the UsdaFoodNutrients for this UsdaFood by matching fdc_id (USDA food identifier)
        UsdaFoodNutrient.where(fdc_id: uf.fdc_id).each do |ufn|
          log_debug("**************")
          log_debug("*** New UsdaFoodNutrient record: #{ufn.inspect}")
          # see if the nutrient is already updated in the FoodNutrient record
          nut = Nutrient.find_by(usda_nutrient_id: ufn.usda_nutrient_id)
          if nut.blank?
            log_error("ERROR: Unable to find usda_nutrient_id for UsdaFood id: #{uf.id}, UsdaFoodNutrient id: #{ufn.usda_nutrient_id}")
          else

            # check for matching FoodNutrient record, or create a new one
            fn = FoodNutrient.find_by(food_id: f.id, nutrient_id: nut.id)
            log_debug("matching food nutrient: #{fn.inspect}")
            if fn.present?
              # confirm the food nutrient record matches this usda food nutrient
              log_error("ERROR: Invalid food_id for FoodNutrient id: #{fn.id}, fn.food_id: #{fn.food_id} != f.id: #{f.id}") if fn.food_id != f.id
              log_error("ERROR: Invalid nutrient_id for FoodNutrient id: #{fn.id}, fn.nutrient_id: #{fn.nutrient_id} != nut.id: #{nut.id}") if fn.nutrient_id != nut.id
            else
              # initialize a new food nutrient record
              fn = FoodNutrient.new()
              fn.food_id = f.id
              fn.nutrient_id = nut.id
              fn.samples_json = {}
              save_food_nut_rec = true
            end

            # update the food nutrient from this Usda food nutrient record
            # create json for samples.json field
            usda_samp = {
              'amount': ufn.amount.to_s,
              'data_points': ufn.data_points.to_s,
              'weight': '1.0',
              'active': true,
              'notes': '',
              'time_entered': Time.now,
              # 'user_entered': '',
            }

            # add/update food nutrient data to samples.json field hash
            if fn.samples_json["fdc,#{ufn.fdc_id.to_s}"].nil?
              fn.samples_json["fdc,#{ufn.fdc_id.to_s}"] = usda_samp
              fn.save
              fn.reload
              log_debug("### updated fn.samples_json: #{fn.samples_json.inspect}")
              save_food_nut_rec = true
            end


            # compute mean from the updated samples.json field
            sum_weighted_amt = 0.0
            n = 0
            fn.samples_json.each do |key, samp|
              # log_debug("### samp: #{samp.inspect}")
              sum_weighted_amt += samp['amount'].to_f * samp['weight'].to_f * samp['data_points'].to_f
              n += (samp['data_points'].present?) ? samp['data_points'].to_i : 1
              # log_debug("### sum_weighted_amt: #{sum_weighted_amt} #{sum_weighted_amt.inspect}")
              # log_debug("### n: #{n} #{n.inspect}")
            end
            mean = fn.amount = sum_weighted_amt / n
            log_debug("### mean: #{mean} #{mean.inspect}")

            # compute sample var from the updated samples.json field
            sum_diff_mean_sq = 0.0
            fn.samples_json.each do |key, samp|
              # log_debug("### samp['amount']: #{samp['amount']} #{samp['amount'].inspect}")
              sum_diff_mean_sq += (samp['amount'].to_f - mean) ** 2
              # log_debug("### sum_diff_mean_sq: #{sum_diff_mean_sq} #{sum_diff_mean_sq.inspect}")
            end
            # log_debug("### sum_diff_mean_sq: #{sum_diff_mean_sq} #{sum_diff_mean_sq.inspect}")
            # log_debug("### n: #{n} #{n.inspect}")
            new_variance = (n > 1) ? sum_diff_mean_sq / (n - 1) : 0
            if fn.variance != new_variance
              fn.variance = new_variance
              save_food_nut_rec = true
            end
          end
          log_debug("### fn: #{fn.inspect}")
          
          log_debug("### About to save.  log_error(: #{get_last_error().inspect}")
          if !error_flagged?() && save_food_nut_rec == true
            # save the record
            log_debug("### Save fn #{fn.inspect}")
            fn.save
            # report any errors
            log_error("ERROR saving FoodNutrient: #{fn.id}, fn.food_id: #{fn.food_id} fn.errors: #{fn.errors.full_messages.join('; ')}") if fn.errors.count > 0
            @report << "Saved food Nutrient: #{f.id}-#{f.name} FoodNutrient: #{fn.id}"
          end
          # log_error('Halt after updating first food nutrient record')
          # raise "Halt"
        end # Loop trough UsdaFoodNutrient records
      else #error_flagged?()
        @errors << "ERROR updating Usda_food.id #{uf.id} fdc_id: #{uf.fdc_id}"
      end
    end # Loop through UsdaFood records

    return
    
  end

  def deact_empty_foods()
    Rails.logger.info("*********************************************************")
    Rails.logger.info("DEACTIVATE EMPTY FOODS")
    Rails.logger.info("*********************************************************")

    @report << "DEACTIVATE EMPTY FOODS"

    exit_msg = ''

    # Loop through all UsdaFood records (to properly put it in a Food record)
    Food.all.each do |f|
      log_debug("**************")
      log_debug("*** Food record: #{f.inspect}")
      break if exit_msg.present?
      reset_error_flag()
      save_food_rec = false

      if f.food_nutrients.count == 0
        log_debug("*** Food record with no nutrients: #{f.id} #{f.name}")
        f.active = false
        save_food_rec = true
        f.save
        log_error("ERROR: Saving Food rec errors: #{f.errors.full_messages.join('; ')}") if f.errors.count > 0
        f.reload()
        log_debug("### Deactivated Food record: #{f.id} #{f.name}")
        @report << "Deactivated food record for #{f.id} #{f.name}"
      end
      
    end
    return
  end

  def update_nutrient_unit_codes()
    Rails.logger.info("*********************************************************")
    Rails.logger.info("UPDATE NUTRIENT UNIT CODES")
    Rails.logger.info("*********************************************************")
    @report << "UPDATE NUTRIENT UNIT CODES"
    exit_msg = ''
    # Loop through all UsdaFood records (to properly put it in a Food record)
    Nutrient.all.each do |n|
      log_debug("**************")
      log_debug("*** Nutrient record: #{n.inspect}")
      break if exit_msg.present?
      reset_error_flag()
      save_nutrient_rec = false
      current_unit_code = n.unit_code
      if LookupTable::DEPRECATED_UNIT_CODES[n.unit_code].present?
        new_unit_code = LookupTable::DEPRECATED_UNIT_CODES[n.unit_code]
        msg = "#{n.name} unit code from #{current_unit_code} to #{new_unit_code}."
        log_debug("*** To update #{msg}")
        n.unit_code = new_unit_code
        save_nutrient_rec = true
        n.save
        log_error("ERROR: Saving Nutrient rec errors: #{n.errors.full_messages.join('; ')}") if n.errors.count > 0
        n.reload()
        log_debug("### Updated #{msg}")
        @report << "### Updated #{msg}"
      elsif LookupTable::VALID_UNIT_CODES[n.unit_code].present?
        msg = "#{n.name} unit code stays at #{current_unit_code}."
        @report << "### OK #{msg}"
      else
        msg = "#{n.name} has invalid unit code of: #{current_unit_code}."
        @report << "### Invalid unit code: #{msg}"
        log_error("### Invalid unit code: #{msg}")
      end
      
    end

    return
  end

  def log_debug(msg)
    @debug << msg
    log_debug(msg) if @debug_mode
  end

  def log_error(msg)
    @errors << msg
    Rails.logger.error(msg)
    @err_msg = msg
  end

  def log_audit(msg)
    if @food_rec_count > 0
      @audit << msg
      log_debug(msg) if @debug_mode
    end
  end

  def reset_error_flag()
    @err_msg = ''
    @prior_errors_count = @errors.count
  end

  def error_flagged?()
    # @err_msg.present?
    @errors.count > @prior_errors_count
  end

  def get_last_error()
    @err_msg
  end


end
