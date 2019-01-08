require 'date'
require 'uri'
require 'active_support/all'

date = Date.parse(ARGV[0])
volume = ARGV[1] || 00
issue = ARGV[2] || 00

params = {
  identifier: "TheVolette#{date.strftime('%Y%m%d')}",
  collection: 'thepacer',
  date: date.strftime('%Y-%m-%d'),
  title: "The Volette - #{date.strftime('%B %-e, %Y')}",
  description: 'Courtesy Tennessee State Library and Archives (Microfilm Accession Number 912)',
  creator: 'The Volette',
  subject: 'student newspaper,ut martin,tennessee-martin',
  language: 'eng',
  volume: volume,
  issue: issue
}

url = "https://archive.org/upload/?#{params.to_param}".gsub('+', '%20')

`open "#{url}"`
