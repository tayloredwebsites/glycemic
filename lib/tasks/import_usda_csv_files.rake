namespace :import_usda_csv_files do
  task perform: :environment do
    ImportUsdaCsvFiles.perform()
  end
end
