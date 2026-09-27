require 'nokogiri'

identifier = ARGV[0]
if identifier.nil?
  puts "Usage: #{__FILE__} <identifier>"
  exit(1)
end

folder = File.join("/Users/#{ENV['LOGNAME']}/Downloads", identifier)
meta_file = File.join(folder, "#{identifier}_meta.xml")
unless File.exist?(meta_file)
  puts "[Error] #{meta_file} not found. Run create-upload-folder.rb first."
  exit(1)
end

pdfs = Dir.glob(File.join(folder, '*.pdf'))
if pdfs.count != 1
  puts "[Error] Expected one PDF in #{folder}, found #{pdfs.count}."
  exit(1)
end

# IA rejects uploaded _meta.xml files, so send its fields as metadata headers instead
metadata = Nokogiri::XML(File.read(meta_file)).root.element_children.flat_map do |el|
  ['-m', "#{el.name}:#{el.text}"]
end

exit(system('ia', 'upload', identifier, pdfs.first, *metadata, '--retries', '10', '--verify', *ARGV[1..]) ? 0 : 1)
