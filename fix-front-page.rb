require 'fileutils'
require 'nokogiri'

identifier = ARGV[0]
if identifier.nil?
  puts "Usage: #{__FILE__} <identifier>"
  exit(1)
end

# Download the identifier's scandata file
`ia download #{identifier} --no-directories --glob=*_scandata.xml`

files = Dir.glob('*_scandata.xml')
if files.count.zero?
  puts '[Error] No scandata file found.'
  exit(1)
elsif files.count > 1
  puts "[Error] More than one scandata file found. #{files.inspect}"
  exit(1)
end

filename = files.first
xml = File.read(filename)
doc = Nokogiri::XML(xml)

# Find element labeled 'Title' and set it to 'Normal'
el = doc.css('book pageData page pageType:contains("Title")')
el.first.content = el.first.content.gsub(/Title/, 'Normal') unless el.first.nil?

# Find first element in set and set it to 'Title'
el = doc.css('book pageData page[leafNum="0"] pageType')
el.first.content = el.first.content.gsub(/Normal/, 'Title')

# Write the updated file to disk
File.write(filename, doc.to_xml)

# Submit the updated file
`ia upload #{identifier} #{filename}`

# Remove the once complete
File.unlink(filename)
