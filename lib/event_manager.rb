require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

puts 'EventManager initialized.'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def clean_phone_number(homephone)
  homephone.gsub!(/[^0-9]/, '')

  unless homephone.to_s.length == 10
    return (homephone.to_s.length == 11) && (homephone.to_s[0] == "1") ? homephone.to_s.slice(1, 10) : ''   
  end
  
  return homephone
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def get_attendees()
    CSV.open(
    'event_attendees.csv',
    headers: true,
    header_converters: :symbol
  )
end

def write_letters()
  attendees = get_attendees()

  template_letter = File.read('form_letter.erb')
  erb_template = ERB.new template_letter

  attendees.each do |row|
    id = row[0]
    name = row[:first_name]
    homephone = clean_phone_number(row[:homephone])
    zipcode = clean_zipcode(row[:zipcode])
    legislators = legislators_by_zipcode(zipcode)

    form_letter = erb_template.result(binding)

    save_thank_you_letter(id,form_letter)
  end
end

def analyse_registration_times()
  hour_counts = get_attendees().each_with_object(
    Hash.new(0)) do |row, new_hash|
      new_hash[row[:regdate].split(' ')[1].split(':')[0]] += 1  
  end
  
  puts 'Most popular registration hour: ' + hour_counts.max_by{|k,v| v}[0].to_s + ":00"
end

def analyse_registration_dates()
  day_counts = get_attendees().each_with_object(
    Hash.new(0)) do |row, new_hash|
      row[:regdate].gsub!('08', '2008')
      new_hash[Date.strptime(row[:regdate], '%m/%d/%Y').strftime('%A')] += 1
  end

  puts 'Most popular registration day: ' + day_counts.max_by{|k,v| v}[0].to_s
end

# Run V1 Only
# write_letters()

# Run V2 Only
# analyse_registration_times()

# Run V3 only
analyse_registration_dates()


