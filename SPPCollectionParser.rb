#!/usr/bin/env ruby

require "/home/griffinj/ruby.d/ruby-tools/spp/SPPParser"

path = ARGV[0]
VERBOSE = true

def writeToFiles(path)

  begin

    # Problematic documents
    if path.match(/\/553K04M1$/)

      return
    end
    
    puts "Parsing #{path}" if VERBOSE
    parser = SPPParser.new path  
    parser.parse
  rescue NoteBeneFileException => nBEx
    
    puts "Warning: #{nBEx.message}"
  end
end

def traverseDir(dirPath)

  Dir.entries(dirPath).each do |filePath|

    if not File.directory? "#{dirPath}/#{filePath}"
      
      writeToFiles "#{dirPath}/#{filePath}"
    else

      traverseDir "#{dirPath}/#{filePath}" if not ['.', '..'].include? filePath
    end
  end
end

traverseDir(path)
