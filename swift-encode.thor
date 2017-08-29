#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'thor'
require "#{File.dirname(__FILE__)}/SwiftPoetryProject"

require 'parseconfig'
config = ParseConfig.new(File.join(File.dirname(__FILE__), 'config/server.conf').chomp)

NB_STORE_PATH = config['nb_store_path']
FILE_STORE_PATH = config['file_store_path']
DOCX_STORE_PATH = config['docx_store_path']
TEITODOCX_BIN_PATH = config['teitodocx_bin_path']

REPORT_EMAIL_ADDRESS = config['report_email_address']

nb_excluded_files = File.join(File.dirname(__FILE__), 'config/excluded_files.yml').chomp
NB_EXCLUDED_FILES = YAML.load(File.read(nb_excluded_files))

COLLATION='collation'
READING='reading'

APPLICATION_NAME = 'Swift Poems Project Transcription Service'
CLIENT_SECRETS_PATH = File.join(File.dirname(__FILE__), 'config', 'client_secret.json')
CREDENTIALS_PATH = File.join(File.dirname(__FILE__), 'config', "gdrive_credentials.yaml")
require 'google/apis/drive_v3'
SCOPE = Google::Apis::DriveV3::AUTH_DRIVE_READONLY
require 'mail'



class Swift < Thor
  package_name "Swift"

  no_commands do
    def nota_bene_store
      SwiftPoemsProject::NotaBeneGDriveStore.new(CLIENT_SECRETS_PATH, SCOPE, APPLICATION_NAME, NB_EXCLUDED_FILES)
    end
  end

  desc "validate", "validate the encoding for the Swift Poems Project transcripts"
  def validate()
    transcripts = []
    transcripts_encoded = []

    report = CSV.open('validate_report.csv', 'wb') do |csv|

      csv << ['SOURCE_ID', 'POEM_ID', 'WAS_ENCODED']

      Dir.glob( "#{NB_STORE_PATH}/**/*" ).select { |path| SwiftPoemsProject::includes?(path) and not File.directory?(path) }.each do |transcript_file_path|
        transcript_file_name = File.basename(transcript_file_path)
        source = File.basename(File.expand_path("..", transcript_file_path))
        transcripts << transcript_file_name

        # puts "Checking for the transcript #{transcript_file_name}..."

        transcript_files = Dir.glob( "#{FILE_STORE_PATH}/sources/**/#{transcript_file_name}.tei.xml" )

        if transcript_files.empty?
          puts "Found #{transcript_file_path}?: #{(!transcript_files.empty?).to_s}"
        end

        # Generate the CSV report
        csv << [ source, transcript_file_name, (!transcript_files.empty?).to_s ]
      end
    end
  end

  desc "encode_transcript SOURCE TRANSCRIPT", "encode the transcript TRANSCRIPT into the TEI-P5"
  def encode_transcript(source, transcript_id)

    @nota_bene_store = SwiftPoemsProject::NotaBeneGDriveStore.new(CLIENT_SECRETS_PATH, SCOPE, APPLICATION_NAME)
    @encoder = SwiftPoemsProject::TeiEncoder.new
    
    # transcript_content = @nota_bene_store.transcript(transcript_id)
    result = @nota_bene_store.transcript(transcript_id)

    transcript_content = result[:content].encode('utf-8','cp437')
    transcript_xml_content = @encoder.encode(source, transcript_id, transcript_content, result[:mtime])
    
    puts transcript_xml_content
  end

  desc "encode_poems", "encode all transcripts within all poems"
  def encode_poems()
    @encoder = SwiftPoemsProject::TeiEncoder.new

    report_file_name = "swift_poems_project_encode_" + DateTime.now.strftime('%Y_%m_%d_%H_%M') + '.csv'
    report_file_path = File.join(File.dirname(__FILE__), 'tmp', report_file_name)

    nota_bene_dir_path = File.join(File.dirname(__FILE__), 'tmp', '**', '*')

    CSV.open(report_file_path, "wb") do |csv|
      csv << ["Transcript ID", "Last Modified Time in Cache", "Encoding Status"]

      Dir[nota_bene_dir_path].each do |file_name|

        file_base_name = File.basename(file_name)
        if file_base_name.length == 8
          
          puts "Encoding #{file_name}..."

          transcript_id = file_base_name
          transcript_content = File.read(file_name)
          transcript_content = transcript_content.encode('utf-8','cp437')
          cached_mtime = File.mtime(file_name)
          cached_mtime = DateTime.parse(cached_mtime.to_s)

          status = 'Success'
          message = ''
          begin
            @encoder.encode(nil, transcript_id, transcript_content, cached_mtime)
          rescue => ex
            status = 'Failure'
            message = ex.message
          end

          csv << [transcript_id, cached_mtime, status, message]
        end
      end
    end

    return if REPORT_EMAIL_ADDRESS.empty?

    mail = Mail.new do
      from     'no-reply@swift.lafayette.edu'
      to       REPORT_EMAIL_ADDRESS
      subject  "Swift Poems Project Encoding Report for #{DateTime.now.strftime('%Y_%m_%d')}"
      body     "Please find attached the report for the latest encoding of Nota Bene files."
      add_file :filename => report_file_name, :content => File.read(report_file_path)
    end

    mail.deliver!
  end

  desc "sync_poems", "encode all transcripts within all poems"
  def sync_poems()
    
    report_file_name = "swift_poems_project_encode_" + DateTime.now.strftime('%Y_%m_%d_%H_%M') + '.csv'
    report_file_path = File.join(File.dirname(__FILE__), 'tmp', report_file_name)

    CSV.open(report_file_path, "wb") do |csv|
      csv << ["Transcript ID", "Last Modified Time on Google Drive"]

      nota_bene_store.poems.each do |result|
        transcript_id = result[:id]
        transcript_mtime = result[:mtime]
        transcript_content = result[:content].encode('utf-8','cp437')
        
#        transcript_status = 'Success'
#        begin
          # @encoder.encode(source, transcript_id, transcript_content, result[:mtime])
#          nil
#        rescue
#          transcript_status = 'Failure'
#        end

        csv << [transcript_id, transcript_mtime]
      end
    end

    return if REPORT_EMAIL_ADDRESS.empty?

    mail = Mail.new do
      from     'no-reply@swift.lafayette.edu'
      to       REPORT_EMAIL_ADDRESS
      subject  "Swift Poems Project Synchronization Report for #{DateTime.now.strftime('%Y_%m_%d')}"
      body     "Please find attached the report for the latest synchronization of Nota Bene files from Google Drive."
      add_file :filename => report_file_name, :content => File.read(report_file_path)
    end

    mail.deliver!
  end

  desc "encode_poem POEM", "encode all transcripts for the poem POEM into the TEI-P5"
  def encode_poem(poem)

    @nota_bene_store = SwiftPoemsProject::NotaBeneGDriveStore.new(CLIENT_SECRETS_PATH, SCOPE, APPLICATION_NAME)
    @encoder = SwiftPoemsProject::TeiEncoder.new

    @nota_bene_store.transcripts(poem_id: poem).each do |result|

      transcript_id = result[:id]
      transcript_content = result[:content]
      transcript_mtime = result[:mtime]

      transcript_content = transcript_content.encode('utf-8','cp437')
      begin
        puts "Encoding #{transcript_id}..."
        puts @encoder.encode('001A', transcript_id, transcript_content, transcript_mtime)
        puts "Success"
      rescue => ex
        $stderr.puts ex.message
      end
    end
  end

  desc "encode_source SOURCE", "encode all transcripts within the source SOURCE into the TEI"
  def encode_source(source)
    Dir.foreach("#{NB_STORE_PATH}/#{source}").select {|path| path != '.' and path != '..' }.each do |relative_path|
      encode_transcript(source, relative_path)
    end
  end

  desc "structure POEM", "structure all transcripts for the poem POEM into a common directory"
  def structure(poem)
    # Create the poem directory
    Dir.mkdir( "#{FILE_STORE_PATH}/#{poem}" ) unless File.exists?( "#{FILE_STORE_PATH}/#{poem}" )

    Dir.glob( "#{NB_STORE_PATH}/**/#{poem}*" ).each do |file_path|
      relative_path = File.basename(file_path)

      nota_bene = SwiftPoemsProject::NotaBene::Document.new file_path
      transcript = SwiftPoemsProject::Transcript.new nota_bene

      source_path = File.expand_path("#{file_path}/..")
      source = File.basename(source_path)

      unless File.exists? "#{FILE_STORE_PATH}/#{source}/#{relative_path}.tei.xml"

        # Encode the transcript if the TEI Document cannot be found
        Dir.mkdir( "#{FILE_STORE_PATH}/#{source}" ) unless File.exists?( "#{FILE_STORE_PATH}/#{source}" )

        File.write( "#{FILE_STORE_PATH}/#{source}/#{relative_path}.tei.xml", transcript.tei.document.to_xml )
      end

      # Create the symlink
      File.symlink( "#{FILE_STORE_PATH}/#{source}/#{relative_path}.tei.xml", "#{FILE_STORE_PATH}/#{poem}/#{relative_path}.tei.xml" )
    end
  end

  desc "encode_sources", "structure all poems for all transcripts"
  def encode_sources()
    Dir.glob( "#{NB_STORE_PATH}/**/*" ).select {|path| path.match(/#{NB_STORE_PATH}\/.{4}\/.{8}$/) }.each do |poem_file_path|
      poem_file_name = File.basename(poem_file_path)
      poem = poem_file_name[0..3]

      source_path = File.expand_path("#{poem_file_path}/..")
      source = File.basename(source_path)

      # Create the poem directory
      poem_dir_path = "#{FILE_STORE_PATH}/poems/#{poem}"

      Dir.mkdir( poem_dir_path ) unless File.exists?( poem_dir_path )
      file_path = poem_file_path
      relative_path = poem_file_name

      # $stdout.puts "Encoding #{file_path}..."

      nota_bene = SwiftPoemsProject::NotaBene::Document.new file_path
      begin
        transcript = SwiftPoemsProject::Transcript.new nota_bene
      rescue Exception => e
        $stderr.puts "Failed to encode #{file_path}: #{e.message}"
      else

        # Create the source directory
        source_dir_path = "#{FILE_STORE_PATH}/sources/#{source}"
        source_file_path = "#{source_dir_path}/#{relative_path}.tei.xml"

        if File.exists? source_file_path
          File.delete source_file_path
        end

        # $stdout.puts "Encoding #{file_path}..."
        $stdout.puts "Writing #{source_dir_path}/#{relative_path}.tei.xml"

        # Encode the transcript
        Dir.mkdir( source_dir_path ) unless File.exists?( source_dir_path )
        File.write( source_file_path, transcript.tei.document.to_xml )

        $stdout.puts "Linking #{poem_dir_path}/#{relative_path}.tei.xml"

        # Create the symlink
        File.symlink( source_file_path, "#{poem_dir_path}/#{relative_path}.tei.xml" ) unless File.exists?( "#{poem_dir_path}/#{relative_path}.tei.xml" )
      end
    end
  end
end

# Swift.start(ARGV)
