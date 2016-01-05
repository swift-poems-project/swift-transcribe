#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require "#{File.dirname(__FILE__)}/SwiftPoetryProject"
require 'sinatra'
require 'sinatra/cross_origin'
require 'tilt/haml'

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

get '/:collId/:docId' do
  content_type :tei
  file_path = "#{NB_STORE_PATH}/#{params[:collId]}/#{params[:docId]}"
  nota_bene = SwiftPoemsProject::NotaBene::Document.new file_path
  transcript = SwiftPoemsProject::Transcript.new nota_bene
  output = transcript.tei.document.to_xml
end

get '/:collId/:docId/html' do
  file_path = "#{NB_STORE_PATH}/#{params[:collId]}/#{params[:docId]}"
  nota_bene = SwiftPoemsProject::NotaBene::Document.new file_path
  transcript = SwiftPoemsProject::Transcript.new nota_bene
  html_doc = transcript.to_html File.join(File.dirname(__FILE__), 'xslt', 'tei_xhtml.xslt')
  html_doc.to_xml
end

get '/:collId/:docId/teibp' do
  return '"Best Practices for TEI in Libraries" transformations not yet implemented.'
end

get '/:collId/archive' do
  collId = params[:collId]

  # Convert and archive the collection
  begin
    tmpCollDirPath = "tmp/#{collId}"
    
    if not Dir.exists?(tmpCollDirPath)
      Dir.mkdir(tmpCollDirPath, 0755)
    end

    Dir.glob("#{NB_STORE_PATH}/#{collId}/*").select { |path| not /tocheck/.match(path) and not /PUMP/.match(path) and not /ANOTHER/.match(path) and not /tochk/.match(path) and /.{3}\-/.match(path) }.each do |file_path|
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
  system('tar', '-cvzf', "#{collId}.tar.gz", "#{collId}")

  Dir.glob("#{collId}/*xml").each { |tei_doc| File.delete(tei_doc) }

  send_file("#{collId}.tar.gz",
            {
              :filename => "#{collId}.tar.gz",
              :type => 'application/x-gzip'
            })

  Dir.chdir('..')
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
