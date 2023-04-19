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
  task fix_dup_nutrients: :environment do
    puts ""
    puts "point duplicate nutrient records to single active one"
    puts "see dups in console using 'Nutrient.select(:name, :unit_code).group_by(&:name)'"
    n1a = Nutrient.find_by(name: "Oligosaccharides", unit_code: 'MG')
    if n1a.present?
      n1b = Nutrient.find_by(name: "Oligosaccharides", unit_code: 'G')
      if n1b.present?
        puts "setting G Oligosaccharides record id: #{n1b.id} to point to  #{n1a.id}"
        n1b.active = false
        n1b.use_me_id = n1a.id
        n1b.save
      else
        raise "Missing G Oligosaccharides record"
      end
    else
      raise "Missing MG Oligosaccharides record"
    end

    n2a = Nutrient.find_by(name: "Energy", unit_code: 'kJ')
    if n2a.present?
      n2b = Nutrient.find_by(name: "Energy", unit_code: 'KCAL')
      if n2b.present?
        puts "setting KCAL Energy record id: #{n2b.id} to point to  #{n2a.id}"
        n2b.active = false
        n2b.use_me_id = n2a.id
        n2b.save
      else
        raise "Missing KCAL Energy record"
      end
    else
      raise "Missing kJ Energy record"
    end


  end
end
