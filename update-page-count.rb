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
el = doc.css('book bookData leafCount')

if el
  pageCount = el.inner_text.to_i
  `ia metadata #{identifier} --modify=pages:#{pageCount}`
  puts "#{identifier}: #{pageCount}"
else
  puts "#{identifier}: Unable to update page count!"
end

# Remove the once complete
File.unlink(filename)
