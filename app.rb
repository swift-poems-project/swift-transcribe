#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'sinatra'
require 'sinatra/cross_origin'
require 'tilt/haml'
require 'listen'
require 'logger'

require "#{File.dirname(__FILE__)}/SwiftPoetryProject"

require 'parseconfig'
config = ParseConfig.new(File.join(File.dirname(__FILE__), 'config/server.conf').chomp)
set :bind, config['host']
set :port, config['port']
set :file_store_path, config['file_store_path']

NB_STORE_PATH = config['nb_store_path']
FILE_STORE_PATH = config['file_store_path']

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

set :haml, :format => :html5

::Logger.class_eval { alias :write :'<<' }
access_log = ::File.join(::File.dirname(::File.expand_path(__FILE__)), 'log', 'access.log')
$access_logger = ::Logger.new(access_log)
error_logger = ::File.new(::File.join(::File.dirname(::File.expand_path(__FILE__)), 'log', 'error.log'), "a+")
error_logger.sync = true

before do
  env["rack.errors"] =  error_logger
end

# Support for the TEI P5 MIME type within a production environment
configure do
  enable :logging
  use ::Rack::CommonLogger, $access_logger
  mime_type :tei, 'application/tei+xml'
  enable :cross_origin
end

def logger
  $access_logger
end

get '/' do
  haml :index
end

get '/sources' do
  haml :sources, :locals => { :appPath => NB_STORE_PATH, :ignoredDirs => IGNORED_DIRS, :ignoredFiles => IGNORED_FILES }
end

get '/sources/:source_id' do
  haml :source, :locals => { :appPath => NB_STORE_PATH, :ignoredDirs => IGNORED_DIRS, :ignoredFiles => IGNORED_FILES, :source_id => params[:source_id] }
end

get '/transcripts/:poem_id/download' do
  content_type :tei

  source_id = params[:poem_id][-4..-1]
  file_path = "#{NB_STORE_PATH}/#{source_id}/#{params[:poem_id]}"
  nota_bene = SwiftPoemsProject::NotaBene::Document.new file_path
  transcript = SwiftPoemsProject::Transcript.new nota_bene

  # Create the source directory if it doesn't already exist
  Dir.mkdir( "#{settings.file_store_path}/#{source_id}" ) unless File.exists?( "#{settings.file_store_path}/#{source_id}" )

  File.write( "#{settings.file_store_path}/#{source_id}/#{params[:poem_id]}.tei.xml", transcript.tei.document.to_xml )
  output = transcript.tei.document.to_xml
end

get '/transcripts/:poem_id' do
  source_id = params[:poem_id][-4..-1]

  file_path = "#{NB_STORE_PATH}/#{source_id}/#{params[:poem_id]}"
  nota_bene = SwiftPoemsProject::NotaBene::Document.new file_path
  transcript = SwiftPoemsProject::Transcript.new nota_bene
  html_doc = transcript.to_html File.join(File.dirname(__FILE__), 'xslt', 'tei_xhtml.xslt')

  # html_doc.to_xml
  haml :transcript, :locals => { :document => html_doc.to_xml, :transcript_id => params[:poem_id] }
end

get '/poems/:source_id/:poem_id/teibp' do
  return '"Best Practices for TEI in Libraries" transformations not yet implemented.'
end

get '/sources/:source_id/archive' do
  source_id = params[:source_id]

  # Convert and archive the collection
  begin
    tmpCollDirPath = "tmp/#{source_id}"
    
    if not Dir.exists?(tmpCollDirPath)
      Dir.mkdir(tmpCollDirPath, 0755)
    end

    Dir.glob("#{NB_STORE_PATH}/#{source_id}/*").select { |path| not /tocheck/.match(path) and not /PUMP/.match(path) and not /ANOTHER/.match(path) and not /tochk/.match(path) and /.{3}\-/.match(path) }.each do |file_path|
      doc_id = File.basename(file_path)
      teiP5FilePath = "#{tmpCollDirPath}/#{doc_id}.xml"
      
      File.open(teiP5FilePath, 'w') do |teiP5File|
        nota_bene = SwiftPoemsProject::NotaBene::Document.new file_path
        transcript = SwiftPoemsProject::Transcript.new nota_bene
        output = transcript.tei.document.to_xml
      end
    end
  rescue Exception => ex
    $stderr.puts "Error generating the TEIP5-XML Document for #{file_path}: #{ex.message}"
  end
    
  # Compress the XML Documents into a GZipped TArchive
  Dir.chdir('tmp')
  system('tar', '-cvzf', "#{source_id}.tar.gz", "#{source_id}")

  Dir.glob("#{source_id}/*xml").each { |tei_doc| File.delete(tei_doc) }

  send_file("#{source_id}.tar.gz",
            {
              :filename => "#{source_id}.tar.gz",
              :type => 'application/x-gzip'
            })

  Dir.chdir('..')
end

# Attempt to integrate a listener for the service
# listener = Listen.to(NB_STORE_PATH, only: [ /.+\/.+{4}\/.+{8}$/ ]) do |modified, added, removed|
listener = Listen.to(NB_STORE_PATH) do |modified, added|
  (modified + added).select { |path| path.match(/.+\/.+{4}\/.+{8}$/) and File.file?(path) }.each do |file_path|
    logger.info "Encoding #{file_path}"

    # Encode the file
    nota_bene = SwiftPoemsProject::NotaBene::Document.new file_path

    begin
      transcript = SwiftPoemsProject::Transcript.new nota_bene
    rescue Exception => e
      logger.info "Failed to encode #{file_path}: #{e.message}"
    else
      source_path = File.expand_path("#{file_path}/..")
      source = File.basename(source_path)

      poem_file_name = File.basename(file_path)
      poem = poem_file_name[0..3]

      Dir.mkdir( "#{FILE_STORE_PATH}/#{source}" ) unless File.exists?( "#{FILE_STORE_PATH}/#{source}" )
      File.write( "#{FILE_STORE_PATH}/#{source}/#{poem_file_name}.tei.xml", transcript.tei.document.to_xml )

      File.symlink( "#{FILE_STORE_PATH}/#{source}/#{poem_file_name}.tei.xml", "#{FILE_STORE_PATH}/#{poem}/#{poem_file_name}.tei.xml" ) unless File.exists?( "#{FILE_STORE_PATH}/#{poem}/#{poem_file_name}.tei.xml" )
    end
  end
end
listener.start
