#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "#{File.dirname(__FILE__)}/SwiftPoetryProject"
require 'sinatra'
require 'sinatra/cross_origin'
require 'haml'

set :bind, '139.147.162.165'
set :port, ARGV[0] if ARGV[0]

post '/xhtml/compare' do

  docs = params.values.map do |docId|

    collId = docId.to_s.split(/\-/)[1]
    SwiftPoetryProject::TeiParser.new("#{SwiftPoetryProject::TeiParser::NB_STORE_PATH}/#{collId}/#{docId}").parse()
  end

  tmpFilePath = "/tmp/swiftpoemsd_#{rand(10000).to_s}.xml"

  File.open(tmpFilePath, 'w') {|f| f.write(SwiftPoetryProject::TeiDocumentSet.new(docs).deeplyIntegrate().to_xml()) }
     
  return Nokogiri::XSLT(File.open("#{File.dirname(__FILE__)}/xslt/spp/xhtml.xsl", 'rb')).transform(Nokogiri.XML(File.open(tmpFilePath, 'rb')), ['class-name', 'swift-poems-project']).to_xml
end

post '/compare' do

  content_type :tei

  docs = params.values.map do |docId|

    collId = docId.to_s.split(/\-/)[1]
    SwiftPoetryProject::TeiParser.new("#{SwiftPoetryProject::TeiParser::NB_STORE_PATH}/#{collId}/#{docId}").parse()
  end

  return SwiftPoetryProject::TeiDocumentSet.new(docs).deeplyIntegrate().to_xml
end

get '/teibp/:collId/:docId' do
  
  return '"Best Practices for TEI in Libraries" transformations not yet implemented.'
end

get '/xhtml/:collId/:docId' do

  @parser = SwiftPoetryProject::TeiParser.new "#{SwiftPoetryProject::TeiParser::NB_STORE_PATH}/#{params[:collId]}/#{params[:docId]}"
  @parser.parse
  @parser.getXhtml.to_xml
end

get '/html/:collId/:docId' do

  return 'HTML transformations not yet implemented'
end

get '/:collId/:docId' do

  content_type :tei

  @parser = SwiftPoetryProject::TeiParser.new "#{SwiftPoetryProject::TeiParser::NB_STORE_PATH}/#{params[:collId]}/#{params[:docId]}"
  @parser.parse.to_xml
end

#error ArchiveError do

#  'Could not generate the gzip-compressed tape archive for the SPP documents'
#end

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
        
              @parser = SwiftPoetryProject::TeiParser.new "#{SwiftPoetryProject::TeiParser::NB_STORE_PATH}/#{collId}/#{docId}"
              teiP5File << @parser.parse.to_xml
            end
          end

        rescue Exception => ex

          $stderr.puts "Error generating the TEIP5-XML Document for #{collId}/#{docId}: #{ex.message}"
        end

=begin
a. omit all the html files
b. omit the first five characters of the file name--so in these cases, omit the leading "06E2_"
c. omit the "tei."
=end
        

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

  haml :index, :locals => { :appPath => "#{settings.root}/master" }
end

# Support for the TEI P5 MIME type within a production environment
configure do

  mime_type :tei, 'application/tei+xml'
  mime_type :tei, 'application/tei+xml'
  enable :cross_origin
end
