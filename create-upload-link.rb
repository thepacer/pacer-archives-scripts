require 'date'
require 'uri'
require 'active_support/all'
require 'optparse'

options = { publication: 'pacer' }
OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} --date DATE [--publication PUBLICATION] [--volume VOLUME] [--issue ISSUE]"
  opts.separator ""
  opts.separator "Specific options:"
  opts.on('-p', '--publication [PUBLICATION]', ['pacer', 'volette'], 'Publication name (pacer or volette) [default: pacer]') do |publication|
    options[:publication] = publication
  end
  opts.on('-d', '--date [DATE]', 'Issue date (YYYY-MM-DD)') do |date|
    options[:date] = date
  end
  opts.on('-v', '--volume [VOLUME]', 'Volume number') do |volume|
    options[:volume] = volume
  end
  opts.on('-i', '--issue [ISSUE]', 'Issue number') do |issue|
    options[:issue] = issue
  end
end.parse!

if options[:date].nil?
  puts "Missing required options! See --help for instructions."
  exit 1
end

date = Date.parse(options[:date])
volume = options[:volume] || '00'
issue = options[:issue] || '00'

# Configure based on publication
if options[:publication] == 'volette'
  publication_config = {
    identifier_prefix: 'TheVolette',
    title_prefix: 'The Volette',
    description: 'Courtesy Tennessee State Library and Archives (Microfilm Accession Number 912)',
    creator: 'The Volette'
  }
elsif options[:publication] == 'pacer'
  publication_config = {
    identifier_prefix: 'ThePacer',
    title_prefix: 'The Pacer',
    description: File.read(File.join(File.dirname(__FILE__), 'Pacer Description.html')),
    creator: 'The Pacer'
  }
else
  puts "Invalid publication: #{options[:publication]}"
  exit 1
end

params = {
  identifier: "#{publication_config[:identifier_prefix]}#{date.strftime('%Y%m%d')}",
  collection: 'thepacer',
  date: date.strftime('%Y-%m-%d'),
  title: "#{publication_config[:title_prefix]} - #{date.strftime('%B %-e, %Y')}",
  description: publication_config[:description],
  creator: publication_config[:creator],
  subject: 'student newspaper;ut martin;tennessee-martin',
  language: 'eng',
  volume: volume,
  issue: issue
}

url = "https://archive.org/upload/?#{params.to_param}".gsub('+', '%20')

`open "#{url}"`
