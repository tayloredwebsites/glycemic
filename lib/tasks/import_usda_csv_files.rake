namespace :import_usda_csv_files do

  task :perform, [:num] => [:environment] do |t, args|
    arg_in = args[:num]
    puts "Perform Step #{arg_in.inspect}"
    report_num = arg_in.to_i
    report, errors = ImportUsdaCsvFiles.perform(report_num)
    # output report to temporary file
    file = File.new("#{Rails.root}/tmp/ImportCsvReport_#{report_num}", 'w')
    begin
      file.write "IMPORT ERROR REPORT\n"
      errors.each do |err_line|
        file.write "#{err_line}\n"
      end
      file.write "\nIMPORT REPORT\n"
      report.each do |line|
        file.write "#{line}\n"
      end
    ensure
      file.close
      # file.unlink   # deletes the temp file
    end
  end

  task :test_report, [:num] => [:environment] do |t, args|
    arg_in = args[:num]
    puts "Test Report for Step #{arg_in.inspect}"
    report_num = arg_in.to_i
    # report, errors = ImportUsdaCsvFiles.perform(report_num)
    @errors = [
      'Error description 1',
      'Error description 2',
      'Error description 3',      
    ]
    @report = [
      'Report Output 1',
      'Report Output 2',
      'Report Output 3',
    ]
    # output report to temporary file
    # file = Tempfile.new("ImportCsvReport_#{report_num}", 'w')
    file = File.new("#{Rails.root}/tmp/ImportCsvReport_#{report_num}", 'w')
    Rails.logger.debug("*** File created: #{file.inspect}")
    begin
      file.write "IMPORT ERROR REPORT\n"
      @errors.each do |err_line|
        file.write "#{err_line}\n"
        Rails.logger.debug("*** wrote: #{err_line}")
      end
      file.write "\nIMPORT REPORT\n"
      @report.each do |line|
        file.write "#{line}\n"
        Rails.logger.debug("*** wrote: #{line}")
      end
    ensure
      # file.close(false)
      file.close
      # file.unlink   # deletes the temp file
    end
  end

  # task perform1: :environment do
  #   report, errors = ImportUsdaCsvFiles.perform(1)
  #   puts ""
  #   puts "Import Csv Files Report"
  #   report.each do |line|
  #     puts line
  #   end
  #   puts ""
  #   puts "perform1 Import Csv Files Errors (#{errors.count}):"
  #   errors.each do |err_line|
  #     puts err_line
  #   end
  # end

  # # task perform2: :environment do
  # #   puts ""
  # #   puts "point duplicate nutrient records to single active one"
  # #   puts "see dups in console using 'Nutrient.select(:name, :unit_code).group_by(&:name)'"
  # #   n1a = Nutrient.find_by(name: "Oligosaccharides", unit_code: 'MG')
  # #   if n1a.present?
  # #     n1b = Nutrient.find_by(name: "Oligosaccharides", unit_code: 'G')
  # #     if n1b.present?
  # #       puts "setting G Oligosaccharides record id: #{n1b.id} to point to  #{n1a.id}"
  # #       n1b.active = false
  # #       n1b.use_this_id = n1a.id
  # #       n1b.save
  # #     else
  # #       raise "Missing G Oligosaccharides record"
  # #     end
  # #   else
  # #     raise "Missing MG Oligosaccharides record"
  # #   end

  # #   n2a = Nutrient.find_by(name: "Energy", unit_code: 'kJ')
  # #   if n2a.present?
  # #     n2b = Nutrient.find_by(name: "Energy", unit_code: 'KCAL')
  # #     if n2b.present?
  # #       puts "setting KCAL Energy record id: #{n2b.id} to point to  #{n2a.id}"
  # #       n2b.active = false
  # #       n2b.use_this_id = n2a.id
  # #       n2b.save
  # #     else
  # #       raise "Missing KCAL Energy record"
  # #     end
  # #   else
  # #     raise "Missing kJ Energy record"
  # #   end
  # # end

  # task perform2: :environment do
  #   report, errors = ImportUsdaCsvFiles.perform(2)
  #   puts ""
  #   puts "Import Csv Files Report"
  #   report.each do |line|
  #     puts line
  #   end
  #   puts ""
  #   puts "perform2 Import Csv Files Errors (#{errors.count}):"
  #   errors.each do |err_line|
  #     puts err_line
  #   end
  # end

  # task perform3: :environment do
  #   report, errors = ImportUsdaCsvFiles.perform(3)
  #   puts ""
  #   puts "Import Csv Files Report"
  #   report.each do |line|
  #     puts line
  #   end
  #   puts ""
  #   puts "perform3 Import Csv Files Errors (#{errors.count}):"
  #   errors.each do |err_line|
  #     puts err_line
  #   end
  # end

  # task perform4: :environment do
  #   report, errors = ImportUsdaCsvFiles.perform(4)
  #   puts ""
  #   puts "Import Csv Files Report"
  #   report.each do |line|
  #     puts line
  #   end
  #   puts ""
  #   puts "perform4 Import Csv Files Errors (#{errors.count}):"
  #   errors.each do |err_line|
  #     puts err_line
  #   end
  # end

end
