#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'thor'
require "#{File.dirname(__FILE__)}/SwiftPoetryProject"

require 'parseconfig'
config = ParseConfig.new(File.join(File.dirname(__FILE__), 'config/server.conf').chomp)

NB_STORE_PATH = config['nb_store_path']
FILE_STORE_PATH = config['file_store_path']

class Swift < Thor
  package_name "Swift"

  desc "encode POEM", "encode the transcript POEM within the source SOURCE into the TEI"
  def encode_poem(poem)
    file_path = nil
    Dir.glob( "#{NB_STORE_PATH}/**/*" ).select {|path| path.match(/#{Regexp.escape(poem)}/) }.each do |poem_file_path|
      file_path = poem_file_path
    end

    if file_path
      poem_stem = File.basename(file_path)[0..3]
      poem_dir_path = "#{FILE_STORE_PATH}/poems/#{poem_stem}"

      source = File.basename(File.expand_path("..", file_path))
      source_dir_path = "#{FILE_STORE_PATH}/sources/#{source}"

      nota_bene = SwiftPoemsProject::NotaBene::Document.new file_path
      transcript = SwiftPoemsProject::Transcript.new nota_bene

      source_file_path = "#{source_dir_path}/#{poem}.tei.xml"

      if File.exists? source_file_path
        File.delete source_file_path
      end

      $stdout.puts "Encoding..."

      # Encode the TEI Document
      File.write(source_file_path, transcript.tei.document.to_xml )

      poem_link_path = "#{poem_dir_path}/#{poem}.tei.xml"

      unless File.exists? poem_link_path

        $stdout.puts "Linking..."

        # Link to the TEI Document
        File.symlink(source_file_path, poem_link_path ) unless File.exists?( poem_link_path )
      end
    end
  end

  desc "encode SOURCE", "encode all transcripts within the source SOURCE into the TEI"
  def encode_source(source)
    Dir.foreach("#{NB_STORE_PATH}/#{source}").select {|path| path != '.' and path != '..' }.each do |relative_path|

      file_path = "#{NB_STORE_PATH}/#{source}/#{relative_path}"

      nota_bene = SwiftPoemsProject::NotaBene::Document.new file_path
      transcript = SwiftPoemsProject::Transcript.new nota_bene

      # Create the source directory if it doesn't already exist
      Dir.mkdir( "#{FILE_STORE_PATH}/#{source}" ) unless File.exists?( "#{FILE_STORE_PATH}/#{source}" )

      File.write( "#{FILE_STORE_PATH}/#{source}/#{relative_path}.tei.xml", transcript.tei.document.to_xml )
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

  desc "encode sources", "structure all poems for all transcripts"
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
