#!/usr/bin/env ruby

require "/home/griffinj/ruby.d/ruby-tools/spp/SPPParser"

path = ARGV[0]

def writeToFiles(path)

begin
  parser = SPPParser.new path

  fileName = path.split(/\//).pop

  File.open(fileName + '.tei.xml', 'w') do |f|

    xml = parser.parse
    puts xml
    f.puts xml
  end

  # Write the original file after the TEI has been successfully generated
  File.open(fileName + '.nb.txt', 'w') do |f|

    f.puts File.read(path, :encoding => 'cp437:utf-8')
  end  

rescue :exception => e

  raise Exception.new "Could not parse file " + path
  end
end

if File.file? path

  writeToFiles path

else File.directory? path

  dir = Dir.entries(path).each do |filePath|
    
    if File.file? filePath

      writeToFiles filePath
    end
  end
end
