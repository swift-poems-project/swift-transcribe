#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'sinatra'
require 'sinatra/cross_origin'
require 'tilt/haml'
require 'listen'
require 'logger'
require 'sidekiq'
require 'redis'
require 'sidekiq/api'
require 'mail'
require 'date'

require "#{File.dirname(__FILE__)}/SwiftPoetryProject"

require 'parseconfig'
config = ParseConfig.new(File.join(File.dirname(__FILE__), 'config/server.conf').chomp)
set :bind, config['host']
set :port, config['port']
set :file_store_path, config['file_store_path']

NB_STORE_PATH = config['nb_store_path']
FILE_STORE_PATH = config['file_store_path']

REDIS_KEY = config['redis_key']
$redis = Redis.new(:host => config['redis_host'], :port => config['redis_post'])

require 'google/apis/drive_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'
APPLICATION_NAME = 'Swift Poems Project Transcription Service'
CLIENT_SECRETS_PATH = File.join(File.dirname(__FILE__), 'config', 'client_secret.json')
CREDENTIALS_PATH = File.join(File.dirname(__FILE__), 'config', "gdrive_credentials.yaml")
SCOPE = Google::Apis::DriveV3::AUTH_DRIVE_READONLY

require 'open-uri'

class TeiEncoderWorker < SwiftPoemsProject::TeiFileEncoder
  include Sidekiq::Worker

  def perform(source_id, transcript_id)
    encode(source_id, transcript_id)
    $redis.lpush(REDIS_KEY, "#{source_id}/#{transcript_id}")
  end
end

class EncodeReporter
  def on_complete(status, options)
    if status.failures != 0

      nil
      # Log the failure
    end
  end

  def on_success(status, options)
  end
end

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
  @nota_bene_store = SwiftPoemsProject::NotaBeneGDriveStore.new(CLIENT_SECRETS_PATH, SCOPE, APPLICATION_NAME)
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

get '/transcripts/:transcript' do
  transcript_id = params.fetch('transcript', nil)

  @encoder = SwiftPoemsProject::TeiEncoder.new

  response = {}
  if transcript_id
    
    result = @nota_bene_store.transcript(transcript_id)

    transcript_content = result[:content].encode('utf-8','cp437')
    response_content = @encoder.encode('001A', transcript_id, transcript_content, result[:mtime])
    
    response = { 'id' => transcript_id, 'tei' => response_content }
  end

  return JSON.generate(response)
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

# Requesting that an individual transcript file be encoded
get '/transcripts/:source_id/:transcript_id/encode' do
  source_id = params[:source_id]
  transcript_id = params[:transcript_id]

  @encoder = SwiftPoemsProject::TeiEncoder.new

  transcript = @nota_bene_store.transcript(transcript_id)
  transcript = transcript.encode('utf-8','cp437')

  return @encoder.encode(source_id, transcript_id, transcript)
end

# Requesting that a transcript be encoded using the data in the response body
post '/transcripts/:source_id/:transcript_id/encode', :provides => 'json' do
  source_id = params[:source_id]
  transcript_id = params[:transcript_id]
  body = request.body.read

  @encoder = SwiftPoemsProject::TeiEncoder.new

  body = body.encode('utf-8','cp437')

  return @encoder.encode(source_id, transcript_id, body)
end

# Handles the request for browsing a poem
get '/poems/:poem', :provides => 'json' do
  poem_id = params.fetch('poem', nil)

  response = []
  # This just returns the poem ID's for the moment
  @nota_bene_store.transcripts(poem_id: poem_id).each do |result|

    transcript_id = result[:id]
    response << transcript_id
  end

  return JSON.generate(response)
end

# Handles the request for browsing all of the poems
get '/poems' do

  poem_ids = []
  Dir.glob( "#{NB_STORE_PATH}/**/*" ).select {|path| path.match(/#{NB_STORE_PATH}\/.+\/.{8}$/) }.each do |poem_file_path|
    transcript_id = File.basename(poem_file_path)
    poem_id = transcript_id[0,4]
    poem_ids << poem_id
  end

  return JSON.generate( poem_ids.uniq.map {|poem_id| {id: poem_id}} )
end

post '/transcripts/encode', :provides => 'json' do

  transcript_id = params.fetch('transcript', nil)
  poem_id = params.fetch('poem', nil)

  @encoder = SwiftPoemsProject::TeiEncoder.new

  response = []
  if transcript_id
    
    # transcript_content = @nota_bene_store.transcript(transcript_id)
    result = @nota_bene_store.transcript(transcript_id)

    transcript_content = result[:content].encode('utf-8','cp437')
    response_content = @encoder.encode('001A', transcript_id, transcript_content, result[:mtime])
    
    response << { 'id' => transcript_id, 'tei' => response_content }

  elsif poem_id

    # This just returns the poem ID's for the moment
    response = []
    @nota_bene_store.transcripts(poem_id: poem_id).each do |result|

      transcript_id = result[:id]
      response << transcript_id
=begin
      transcript_id = result[:id]
      transcript_content = result[:content]
      transcript_mtime = result[:mtime]

      begin
        transcript_content = transcript_content.encode('utf-8','cp437')
        response << @encoder.encode('001A', transcript_id, transcript_content, transcript_mtime)
      rescue
        nil
      end
=end
    end
  end

  return JSON.generate(response)
end

# Handles the request for encoding all of the sources
get '/sources/:source_id/encode' do
  source_id = params[:source_id]

  Dir.foreach("#{NB_STORE_PATH}/#{source_id}").select {|path| path != '.' and path != '..' }.each do |transcript_id|
    EncodeWorker.perform_async(source_id, transcript_id)
  end

  redirect to('/')
end

get '/sources/report' do
  @report = SwiftPoemsProject::Reporting::Report.new(NB_STORE_PATH)
  @report.generate(FILE_STORE_PATH)

  haml :report, :locals => { :report => @report }
end

# Handles the request for encoding all of the sources
get '/sources/encode' do
  Dir.glob( "#{NB_STORE_PATH}/**/*" ).select {|path| path.match(/#{NB_STORE_PATH}\/.{4}\/.{8}$/) }.each do |poem_file_path|
    path_segments = poem_file_path.split('/')
    source_id, transcript_id = path_segments[-2..-1]

    EncodeWorker.perform_async(source_id, transcript_id)
  end

  redirect to('/')
end

# Handles the request for browsing a source
get '/sources/:source_id' do
  source_id = params[:source_id]
  transcript_ids = []

  Dir.glob( "#{NB_STORE_PATH}/#{source_id}/*" ).select {|path| path.match(/#{NB_STORE_PATH}\/.+\/.{8}$/) }.each do |poem_file_path|
    transcript_id = File.basename(poem_file_path)
    transcript_ids << transcript_id unless transcript_ids.include?(transcript_id)
  end

  haml :source, :locals => { :transcript_ids => transcript_ids }
end

# Handles the request for browsing all of the sources
get '/sources' do
  source_ids = []
  Dir.foreach(NB_STORE_PATH) do |collId|
    if collId != '.' and collId != '..' and File.directory? "#{NB_STORE_PATH}/#{collId}" and not IGNORED_FILES.include? collId
      source_ids << collId
    end
  end

  haml :sources, :locals => { :source_ids => source_ids }
end



# Generate the error report

# Transmit the error report
def transmit_report
end

# Handles the request for the index
get '/' do
  haml :index
end

# Attempt to integrate a listener for the service
# listener = Listen.to(NB_STORE_PATH, only: [ /.+\/.+{4}\/.+{8}$/ ]) do |modified, added, removed|
listener = Listen.to(NB_STORE_PATH) do |modified, added|
  (modified + added).select { |path| path.match(/.+\/.+{4}\/.+{8}$/) and File.file?(path) }.each do |poem_file_path|

    path_segments = poem_file_path.split('/')
    source_id, transcript_id = path_segments[-2..-1]

    EncodeWorker.perform_async(source_id, transcript_id)
  end
end
listener.start
puts "Listening for all changes to files within #{NB_STORE_PATH}"
