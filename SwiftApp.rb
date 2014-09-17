#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'active_mdb'
require 'logger'

module SwiftApp

  class Index

    attr_reader :db, :file_path

    def initialize(file_path)

      @file_path = file_path
      @db = MDB.new @file_path
    end

    def query(query)

      puts query
      
      MDBTools.mdb_sql @file_path, query
    end

    class Item

      MODS_DOC =<<EOF
<mods xmlns="http://www.loc.gov/mods/v3" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xlink="http://www.w3.org/1999/xlink">
        <typeOfResource></typeOfResource>
        <!-- To be drafted and refined -->
</mods>
EOF

      def initialize(index)
        
        @index = index
        @doc = Nokogiri::XML(MODS_DOC, &:noblanks)
      end
    end
  end

  class InventoryIndex < Index

    # Assume that this is one in the same as a source (?)
    # tblSourceDatesparsed likely holds the dates related to a given source

    def edition(source_id)

      Edition.new(source_id, self)
    end

    class Edition

      def initialize(source_id, index, table_name = 'tblPoemSources', prefix = 'src')

        @source_id = source_id
        @index = index
        @table_name = table_name

        MDBTools.table_to_csv @index.file_path, table_name
        # @index.db.table_to_csv @index.file_path, table_name
        # @table = Table.new @index.db, table_name, prefix
        # @table.to_csv

#        @index.query("SELECT * FROM tblPoemSources WHERE Source_ID=#{@source_id}").each do |record|

#          puts record
#        end
      end

=begin
    Poem Title
        One preferred title many alternate titles (Nota Bene file; not parsed by the SwiftApp)
        Use of what's in the transcription?
        Implement a Solr array of titles
        Might require manual cleaning
    Poem First Line
        Paul has this (preferred, and alternate)
    Publisher
        Very difficult (normalization problems); "Description of the Source"
        Might come down to manual cleaning
    City of Publication
        Integrated with 
    SPP Source Code
        Straightforward
    ESTC Catalog Number
        When they've located them
        Multiple (from a verse standpoint, sources are identical; same print setting - but ESTC number is consistent)
    Teerink-Scouten Number
        Must be normalized
        Recorded two different ways in two different places
            Ranges (3A - D)
            3A, another entry for 3B...
    Foxon Number
        Same as SPP number...
    Lindsay Number
        (Question J. Woolley regarding this field)
    Full-Text
    Dates
        Recorded as ranges
=end

      # Possibly an abstract Class
      class Source

        def initialize(title,
                       publisher,
                       city_of_publication,
                       source_code,
                       tsnumber, tspage, estc, foxon, lindsay, dates = [])
          
        end
      end
      
      # Different printers' names
      class Issue < Source
        
      end
      
    end
    
    def initialize(file_path)
      
      super(file_path)
      @editions = []
    end
  end
  
  # Multiple tables
  
=begin
    SPP Poem Code
    First Line
        From TEI
    Title
        Same as source
    Author (Attribution)
        Stated at the bottom
        May record collective attributions
            Propagation
            Clarify: Recording for author - stated attributed, or their attribution?
        Capture from the structure of the SPP Poem Code
            Alternate author not stated within SwiftApp
            CANON.XLS
    Headnotes (stripped of markup)
        From TEI
    Footnotes (stripped of markup)
        From TEI
    Date of Composition (datestamps) - Normalization into date ranges
        SwiftApp
    Date of First Publication (datestamps) - Normalization into date ranges
        SwiftApp
        Calculated, not manually entered
    Full-Text
=end

    class Transcript

      def initialize(poem, source, file_path)

        @poem_code
        @title
        @authors
        @date_composition
        @date_publication
      end
    end

    class TranscriptSet
      
      attr_accessor :transcripts

      def initialize

        @transcripts = []
      end
    end
end
