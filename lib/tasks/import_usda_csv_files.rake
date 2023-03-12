namespace :import_usda_csv_files do
  task perform: :environment do
    report, errors = ImportUsdaCsvFiles.perform()
    puts ""
    puts "Import Csv Files Report"
    report.each do |line|
      puts line
    end
    puts ""
    puts "Import Csv Files Errors:"
    errors.each do |err_line|
      puts err_line
    end
  end
end
