require 'date'
require 'uri'
require 'cgi'
require 'fileutils'
require 'active_support/all'
require 'optparse'
require 'optparse/date'

options = { publication: 'pacer' }
OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} --date DATE --volume VOLUME --issue ISSUE --pages PAGES [--publication PUBLICATION]"
  opts.separator ""
  opts.separator "Specific options:"
  opts.on('-p', '--publication [PUBLICATION]', ['pacer', 'volette'], 'Publication name (pacer or volette) [default: pacer]') do |publication|
    options[:publication] = publication
  end
  opts.on('-d', '--date [DATE]', Date, 'Issue date') do |date|
    options[:date] = date
  end
  opts.on('-v', '--volume [VOLUME]', 'Volume number') do |volume|
    options[:volume] = volume
  end
  opts.on('-i', '--issue [ISSUE]', 'Issue number') do |issue|
    options[:issue] = issue
  end
  opts.on('-c', '--pages [PAGES]', 'Page count') do |pages|
    options[:pages] = pages
  end
end.parse!

if options[:date].nil? || options[:volume].nil? || options[:issue].nil? || options[:pages].nil?
  puts "Missing required options! See --help for instructions."
  exit 1
end

username = 'internetarchive@yearg.in'
basedirectory = "/Users/#{ENV['LOGNAME']}/Downloads"

# Configure based on publication
if options[:publication] == 'volette'
  publication_config = {
    identifier_prefix: 'TheVolette',
    title_prefix: 'The Volette',
    description_file: 'Volette Description.html',
    creator: 'The Volette',
    lccn: 'sn2005062321',
    oclc: '50957220'
  }
elsif options[:publication] == 'pacer'
  publication_config = {
    identifier_prefix: 'ThePacer',
    title_prefix: 'The Pacer',
    description_file: 'Pacer Description.html',
    creator: 'The Pacer',
    lccn: 'sn2005062320',
    oclc: '50957347'
  }
else
  puts "Invalid publication: #{options[:publication]}"
  exit 1
end

params = {
  identifier: "#{publication_config[:identifier_prefix]}#{options[:date].strftime('%Y%m%d')}",
  collection: 'thepacer',
  date: options[:date].strftime('%Y-%m-%d'),
  title: "#{publication_config[:title_prefix]} - #{options[:date].strftime('%B %-e, %Y')}",
  description: File.read(File.join(File.dirname(__FILE__), publication_config[:description_file])),
  creator: publication_config[:creator],
  subject: 'student newspaper;ut martin;tennessee-martin',
  language: 'eng',
  lccn: publication_config[:lccn],
  oclc: publication_config[:oclc],
  volume: options[:volume],
  issue: options[:issue],
  pages: options[:pages]
}

# Make the working directory
FileUtils.mkdir_p(File.join(basedirectory, params[:identifier]))

# Write the file manifest
File.open(File.join(basedirectory, params[:identifier], "#{params[:identifier]}_files.xml"), 'w') do |f|
  f.write('<files />')
end

# Write the meta data file
File.open(File.join(basedirectory, params[:identifier], "#{params[:identifier]}_meta.xml"), 'w') do |f|
  f.write "<metadata>\n"
  f.write "  <mediatype>texts</mediatype>\n"
  f.write "  <collection>#{params[:collection]}</collection>\n"
  f.write "  <date>#{params[:date]}</date>\n"
  f.write "  <title>#{CGI.escapeHTML(params[:title])}</title>\n"
  f.write "  <description>#{CGI.escapeHTML(params[:description])}</description>\n"
  f.write "  <creator>#{CGI.escapeHTML(params[:creator])}</creator>\n"
  params[:subject].split(';').each do |subject|
    f.write "  <subject>#{CGI.escapeHTML(subject.strip)}</subject>\n"
  end
  f.write "  <language>#{params[:language]}</language>\n"
  f.write "  <lccn>#{params[:lccn]}</lccn>\n"
  f.write "  <oclc-id>#{params[:oclc]}</oclc-id>\n"
  f.write "  <issue>#{params[:issue]}</issue>\n"
  f.write "  <volume>#{params[:volume]}</volume>\n"
  f.write "  <pages>#{params[:pages]}</pages>\n"
  f.write "</metadata>\n"
end

# Move item from base directory into item folder, if exists
if File.exist? File.join(basedirectory, "#{params[:date]}.pdf")
  FileUtils.mv(File.join(basedirectory, "#{params[:date]}.pdf"), File.join(basedirectory, params[:identifier], "#{params[:date]}.pdf"))
end

# Generate upload URL with preset metadata
upload_url = "https://archive.org/upload/?#{params.to_param}".gsub('+', '%20')
puts "\nFolder created: #{File.join(basedirectory, params[:identifier])}"
puts "Upload URL: #{upload_url}"
