require 'date'
require 'uri'
require 'cgi'
require 'fileutils'
require 'active_support/all'

date = Date.parse(ARGV[0])
volume = ARGV[1] || 00
issue = ARGV[2] || 00
username = 'internetarchive@yearg.in'
basedirectory = "/Users/#{ENV['LOGNAME']}/Downloads"

# params = {
#   identifier: "TheVolette#{date.strftime('%Y%m%d')}",
#   collection: 'thepacer',
#   date: date.strftime('%Y-%m-%d'),
#   title: "The Volette - #{date.strftime('%B %-e, %Y')}",
#   description: CGI::escapeHTML(File.read(File.join(File.dirname(__FILE__), 'Volette Description.html'))),
#   creator: 'The Volette',
#   subject: 'student newspaper,ut martin,tennessee-martin',
#   language: 'eng',
#   lccn: 'sn2005062321',
#   oclc: '50957220',
#   volume: volume,
#   issue: issue
# }

params = {
  identifier: "ThePacer#{date.strftime('%Y%m%d')}",
  collection: 'thepacer',
  date: date.strftime('%Y-%m-%d'),
  title: "The Pacer - #{date.strftime('%B %-e, %Y')}",
  description: CGI::escapeHTML(File.read(File.join(File.dirname(__FILE__), 'Pacer Description.html'))),
  creator: 'The Pacer',
  subject: 'student newspaper,ut martin,tennessee-martin',
  language: 'eng',
  lccn: 'sn2005062320',
  oclc: '50957347',
  volume: volume,
  issue: issue
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
  f.write "  <title>#{params[:title]}</title>\n"
  f.write "  <description>#{params[:description]}</description>\n"
  f.write "  <creator>#{params[:creator]}</creator>\n"
  params[:subject].split(',').each do |subject|
    f.write "  <subject>#{subject}</subject>\n"
  end
  f.write "  <language>#{params[:language]}</language>\n"
  # NOTE: Lines below will overwrite other metadata; See link below for possible alternatives
  # https://help.archive.org/hc/en-us/articles/360018818271-Internet-Archive-Metadata
  # f.write "  <lccn>#{params['lccn']}</lccn>",
  # f.write "  <oclc-id>#{params['oclc']}</oclc-id>",
  f.write "  <issue>#{params[:issue]}</issue>\n"
  f.write "  <volume>#{params[:volume]}</volume>\n"
  f.write "</metadata>\n"
end

# Move item from base directory into item folder, if exists
if File.exists? File.join(basedirectory, "#{params[:date]}.pdf")
  FileUtils.mv(File.join(basedirectory, "#{params[:date]}.pdf"), File.join(basedirectory, params[:identifier], "#{params[:date]}.pdf"))
end

puts "https://archive.org/services/contrib-submit.php?user_email=#{username}&server=items-uploads.archive.org&dir=#{params[:identifier]}"
