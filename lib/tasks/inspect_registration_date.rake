desc "Inspect user registration date and export CSV file with result"
task :inspect_registration_date, [:file] => :environment do |task, args|
  # Step 1. read importing CSV data
  csv_contents = CSV.read(args[:file].pathmap, headers: true)

  # Step 2. inspect user registration date and fill in result
  csv_contents.each do |row|
    email = row['Email']

    # activity period
    activity_start_date = DateTime.new(2019, 12, 24)
    activity_end_date = DateTime.new(2019, 12, 31, 23).end_of_hour

    user_registration_date = User.find_by(email: email).created_at
    next row['Result'] = "此 Email 非在期間內註冊" unless user_registration_date.between?(activity_start_date, activity_end_date)
    row['Result'] = "此 Email 註冊於期間內"
  end

  # Step.3 export CSV file with result
  file_name = File.basename(args[:file], '.csv')
  File.open("/tmp/#{file_name}_result.csv", 'w') do |file|
    file.write(csv_contents)
  end
end
