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
  end

  def run()
    msg = "Start of Importing of USDA CSV files"
    Rails.logger.debug("*** #{msg}")
    @report << msg

    # read in usda categories into lookup tables:
    filename = Rails.root.join('db','csv_uploads','food_category.csv')
    options = {:chunk_size => 10} # {:key_mapping => {:unwanted_row => nil, :old_row_name => :new_name}}
    n = SmarterCSV.process(filename, options) do |array|
      # we're passing a block in, to process each resulting hash / =row (the block takes array of hashes)
      # when chunking is not enabled, there is only one hash in each array
      # Rails.logger.debug("@@@ read chunk #{array.inspect}")
      array.each do |row|
        Rails.logger.debug("@@@ read line #{row.inspect}")
      end
      # MyModel.create( array.first )
    end
    Rails.logger.debug("@@@ read #{n} lines")

    # read in wweia categories into lookup tables:
    filename = Rails.root.join('db','csv_uploads','wweia_food_category.csv')
    options = {:chunk_size => 10} # {:key_mapping => {:unwanted_row => nil, :old_row_name => :new_name}}
    n = SmarterCSV.process(filename, options) do |array|
      # we're passing a block in, to process each resulting hash / =row (the block takes array of hashes)
      # when chunking is not enabled, there is only one hash in each array
      # Rails.logger.debug("@@@ read chunk #{array.inspect}")
      array.each do |row|
        Rails.logger.debug("@@@ read line #{row.inspect}")
      end
      # MyModel.create( array.first )
    end
    Rails.logger.debug("@@@ read #{n} lines")
    
  end

end
