#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "#{File.dirname(__FILE__)}/SwiftPoetryProject"
require 'sinatra'
require 'sinatra/cross_origin'
require 'haml'

require 'parseconfig'
config = ParseConfig.new(File.join(File.dirname(__FILE__), 'config/server.conf').chomp)
set :bind, config['host']
set :port, config['port']
set :fileStorePath, config['file_store_path']

NB_STORE_PATH = config['nb_store_path']

IGNORED_DIRS = [
                'TEI-samp',
                'BIBLS',
                'CASE',
                'PRSOURCE',
                'MSSOURCE',
                'EDIT',
                'DESCRIBE',
                '4DOS750',
                'HW37',
                'XML-Test',
                'incoming',
                'POEMCOLL',
                'NB',
                'NEWDOS',
                'INSTALL',
                'FAULKNER',
                'STEMMAS',
                'FAIRBROT',
                'INV'
               ]

IGNORED_FILES = [
                 'tocheck',
                 'PUMP',
                 'tochk',
                 'TOCHECK',
                 'proofed.by',
                 'pages',
                 '!W61500B',
                 'README',
                 'M63514W2',
                 'FULL.NB3',
                 'FULLTEXT.HTM',
                 'FILL@.NB3',
                 'TRANS',
                 'NEWFULL.RTF',
                 'ANOTHER',
                 'Z725740L',
                 'Smythe of Barbavilla.doc',
                 'Y08B002H',
                 'Z787600L',
                 'SOURCES'
                ]

post '/xhtml/compare' do

  docs = params.values.map do |docId|

    collId = docId.to_s.split(/\-/)[1]
    SwiftPoetryProject::TeiParser.new("#{NB_STORE_PATH}/#{collId}/#{docId}").parse()
  end

  tmpFilePath = "/tmp/swiftpoemsd_#{rand(10000).to_s}.xml"

  File.open(tmpFilePath, 'w') {|f| f.write(SwiftPoetryProject::TeiDocumentSet.new(docs).deeplyIntegrate().to_xml()) }
     
  return Nokogiri::XSLT(File.open("#{File.dirname(__FILE__)}/xslt/xhtml.xsl", 'rb')).transform(Nokogiri.XML(File.open(tmpFilePath, 'rb')), ['class-name', 'swift-poems-project']).to_xml
end

post '/compare' do

  content_type :tei

  docs = params.values.map do |docId|

    collId = docId.to_s.split(/\-/)[1]
    SwiftPoetryProject::TeiParser.new("#{NB_STORE_PATH}/#{collId}/#{docId}").parse()
  end

  return SwiftPoetryProject::TeiDocumentSet.new(docs).deeplyIntegrate().to_xml
end

get '/teibp/:collId/:docId' do
  
  return '"Best Practices for TEI in Libraries" transformations not yet implemented.'
end

get '/xhtml/:collId/:docId' do

  @parser = SwiftPoetryProject::TeiParser.new "#{NB_STORE_PATH}/#{params[:collId]}/#{params[:docId]}"
  @parser.parse
  @parser.getXhtml.to_xml
end

get '/html/:collId/:docId' do

  return 'HTML transformations not yet implemented'
end

#error ArchiveError do

#  'Could not generate the gzip-compressed tape archive for the SPP documents'
#end

get '/archive/:collId' do

  collId = params[:collId]

  # Convert and archive the collection
#  begin

  tmpCollDirPath = "tmp/#{collId}"

  if not Dir.exists?(tmpCollDirPath)

    Dir.mkdir(tmpCollDirPath, 0755)
  end

  Dir.glob("#{NB_STORE_PATH}/#{collId}/*").select { |path| not /tocheck/.match(path) and not /PUMP/.match(path) and not /ANOTHER/.match(path) and not /tochk/.match(path) and /.{3}\-/.match(path) }.each do |file_path|

    doc_id = File.basename(file_path)
    teiP5FilePath = "#{tmpCollDirPath}/#{doc_id}.xml"
      
    File.open(teiP5FilePath, 'w') do |teiP5File|
        
      @parser = SwiftPoetryProject::TeiParser.new file_path
      teiP5File << @parser.parse.to_xml
    end
  end

#  rescue Exception => ex

#    $stderr.puts "Error generating the TEIP5-XML Document for #{file_path}: #{ex.message}"
#  end

  # Compress the XML Documents into a GZipped TArchive
  # puts 'tar' + ' -cvzf' + " tmp/#{collId}.tar.gz" + ' tmp/*xml'

  Dir.chdir('tmp')
  system('tar', '-cvzf', "#{collId}.tar.gz", "#{collId}")

  Dir.glob("#{collId}/*xml").each { |tei_doc| File.delete(tei_doc) }

  send_file("#{collId}.tar.gz",
            {
              :filename => "#{collId}.tar.gz",
              :type => 'application/x-gzip'
            })

  Dir.chdir('..')
end

get '/:collId/:docId' do

  content_type :tei

  @parser = SwiftPoetryProject::TeiParser.new "#{NB_STORE_PATH}/#{params[:collId]}/#{params[:docId]}"

  doc = @parser.parse
  doc.to_xml
end

get '/file-store' do

  # appPath = "#{settings.root}/master"
  appPath = "#{NB_STORE_PATH}"

  Dir.foreach(appPath).select { |path| not /SIC/.match path and not /UNDERDOT/.match path and File.directory? path }.each do |collId|

    # Make the directory
    Dir.mkdir "#{settings.fileStorePath}/#{collId}" unless Dir.exists? "#{settings.fileStorePath}/#{collId}"

    Dir.foreach("#{appPath}/#{collId}").select {|path| not /tocheck/.match(path) and not /PUMP/.match(path) and not /tochk/.match(path) and not /TOCHECK/.match(path) and not /proofed\.by/.match(path) and not /pages$/.match(path) and not /!W61500B/.match(path) and not /README$/.match(path) and not /M63514W2/.match(path) and not /FULL\.NB3/.match(path) and not /FULLTEXT\.HTM/.match(path) and not /FULL@\.NB3/.match(path) and not /TRANS/.match(path) and not /NEWFULL\.RTF/.match(path) and not /TR$/.match(path) and not /ANOTHER/.match(path) and not /Z725740L/.match(path) and not /Smythe of Barbavilla\.doc/.match(path) and not /Y08B002H/.match(path) }.each do |docId|

      if docId != '.' and docId != '..' and not File.directory? "#{appPath}/#{collId}/#{docId}" and not /^\./.match(docId)

        witnessPath = "#{appPath}/#{collId}/#{docId}"
        transformedPath = "#{settings.fileStorePath}/#{collId}/#{docId}.tei.xml"
        begin

          @parser = SwiftPoetryProject::TeiParser.new witnessPath
          tei_xml = @parser.parse.to_xml

          logger.info "Writing to #{transformedPath}"
          File.open("#{transformedPath}", 'wb') do |file|

            file.write(tei_xml)
          end
        rescue Exception => e

          logger.warn "Failed to transform #{witnessPath}: #{e.message}"
        end
      end
    end
  end
end

get '/archive' do

  appPath = "#{settings.root}/master"

  if not Dir.exists?('tmp')

    Dir.mkdir('tmp', 0755) 
  end

  Dir.foreach(appPath) do |collId|

    Dir.foreach("#{appPath}/#{collId}") do |docId|

      unless docId == '.' or docId == '..'

        # "/spp/#{collId}/#{docId}"} #{docId} (TEI P5)
        begin

          tmpCollDirPath = "tmp/#{collId}"

          if not Dir.exists?(tmpCollDirPath)

            Dir.mkdir(tmpCollDirPath, 0755) 
          end

          teiP5FilePath = "#{tmpCollDirPath}/#{docId}.xml"

          if not File.exists?(teiP5FilePath)

            File.open(teiP5FilePath, 'w') do |teiP5File|
        
              @parser = SwiftPoetryProject::TeiParser.new "#{NB_STORE_PATH}/#{collId}/#{docId}"
              teiP5File << @parser.parse.to_xml
            end
          end

        rescue Exception => ex

          $stderr.puts "Error generating the TEIP5-XML Document for #{collId}/#{docId}: #{ex.message}"
        end
      end
    end
  end

  # Compress the XML Documents into a GZipped TArchive
  if not system('tar', 'cvzf', 'tmp/spp.tar.gz', 'tmp/*xml')

    raise 500
  else

    send_file('tmp/spp.tar.gz',
              {
                :type => 'application/x-gzip'
              })
  end
end



set :haml, :format => :html5

get '/' do

  haml :index, :locals => { :appPath => NB_STORE_PATH, :ignoredDirs => IGNORED_DIRS, :ignoredFiles => IGNORED_FILES }
end

# Support for the TEI P5 MIME type within a production environment
configure do

  mime_type :tei, 'application/tei+xml'
  enable :cross_origin
end
