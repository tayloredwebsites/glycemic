namespace :import_usda_csv_files do

  task :test_args, [:arg1, :arg2] do |t, args|
    puts "Args were: #{args} of class #{args.class}"
    puts "args[:arg1] was: '#{args[:arg1]}' of class #{args[:arg1].class}"
    puts "args[:arg2] was: '#{args[:arg2]}' of class #{args[:arg2].class}"
  end
  
  task :perform, [:num, :debug_flag] => [:environment] do |t, args|
    arg_in = args[:num]
    deb_arg = (args[:debug_flag] == false) ? false : (args[:debug_flag] == true) ? true : false
    puts "Perform Step #{arg_in.inspect} with debug_mode: #{deb_arg}"
    report_num = arg_in.to_i
    report, errors, debug, audit = ImportUsdaCsvFiles.perform(report_num, deb_arg)
    # output report to file in /tmp directory
    tmpFile = "#{Rails.root}/tmp/ImportCsvReport_#{report_num}"
    # Write over any previous reports for this step
    file = File.new(tmpFile, 'w')
    begin
      file.write "IMPORT ERROR REPORT\n"
      errors.each do |err_line|
        file.write "#{err_line}\n"
      end
      file.write "\nIMPORT REPORT\n"
      report.each do |line|
        file.write "#{line}\n"
      end
      file.write "\nIMPORT DEBUG REPORT\n"
      report.each do |line|
        file.write "#{line}\n"
      end
      file.write "\nIMPORT AUDIT  REPORT\n"
      report.each do |line|
        file.write "#{line}\n"
      end
    ensure
      file.close
      # file.unlink   # deletes the temp file
      puts "Step #{arg_in.inspect} is done"
      puts "\nReports can be found at at: #{tmpFile}"
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

end
