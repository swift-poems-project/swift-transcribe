# -*- coding: utf-8 -*-

require_relative 'spec_helper'

describe 'TeiParser' do

  before :each do

    @nb_store_path = '/var/lib/spp/master'
  end

  describe 'collection parsing' do
    
    @nb_store_path = '/var/lib/spp/master'

    Dir.glob("#{@nb_store_path}/*").select {|path| not /TEI-samp/.match path and not /BIBLS/.match path and not /CASE/.match path and not /PRSOURCE/.match path and not /MSSOURCE/.match path  and not /EDIT/.match path  and not /DESCRIBE/.match path and not /4DOS750/.match path and not /HW37/.match path and not /XML-Test/.match path and not /incoming/.match path and not /POEMCOLL/.match path and not /NB/.match path and not /NEWDOS/.match path and not /INSTALL/.match path and not /FAULKNER/.match path and not /STEMMAS/.match path and not /FAIRBROT/.match path and not /INV/.match path }.each do |coll_path|

=begin
      describe "parses all Nota Bene documents within the collection #{coll_path}" do

        @nb_store_path = '/var/lib/spp/master'

        Dir.glob("#{coll_path}/*").select {|path| not /tocheck/.match(path) and not /PUMP/.match(path) and not /tochk/.match(path) and not /TOCHECK/.match(path) and not /proofed\.by/.match(path) and not /pages$/.match(path) and not /!W61500B/.match(path) and not /README$/.match(path) and not /M63514W2/.match(path) and not /FULL\.NB3/.match(path) and not /FULLTEXT\.HTM/.match(path) and not /FULL@\.NB3/.match(path) and not /TRANS/.match(path) and not /NEWFULL\.RTF/.match(path) and not /TR$/.match(path) and not /ANOTHER/.match(path) and not /Z725740L/.match(path) and not /Smythe of Barbavilla\.doc/.match(path) and not /Y08B002H/.match(path) }.each do |file_path|

          it "parses all Nota Bene documents within the collection #{file_path}" do

            expect {
              
              puts file_path

              @parser = SwiftPoetryProject::TeiParser.new "#{file_path}"
              @parser.parse.to_xml

              # puts @parser.parse.to_xml
            }.to_not raise_error
          end
        end
      end

      describe "parses all Nota Bene tokens within the collection #{coll_path}" do

        @nb_store_path = '/var/lib/spp/master'

        Dir.glob("#{coll_path}/*").select {|path| not /tocheck/.match(path) and not /PUMP/.match(path) and not /tochk/.match(path) and not /TOCHECK/.match(path) and not /proofed\.by/.match(path) and not /pages$/.match(path) and not /!W61500B/.match(path) and not /README$/.match(path) and not /M63514W2/.match(path) and not /FULL\.NB3/.match(path) and not /FULLTEXT\.HTM/.match(path) and not /FULL@\.NB3/.match(path) and not /TRANS/.match(path) and not /NEWFULL\.RTF/.match(path) and not /TR$/.match(path) and not /ANOTHER/.match(path) and not /Z725740L/.match(path) and not /Smythe of Barbavilla\.doc/.match(path) and not /Y08B002H/.match(path) }.each do |file_path|

          it "parses all Nota Bene tokens within the document #{coll_path}" do

            expect {

              puts file_path

              @parser = SwiftPoetryProject::TeiParser.new "#{file_path}"
              results = @parser.parse.to_xml
              expect(results).not_to match(/«MD..»/)
            }.to_not raise_error
          end
        end
      end
=end

      it "parses all Nota Bene documents within the collection #{coll_path}" do

        Dir.glob("#{coll_path}/*").select {|path| not /tocheck/.match(path) and not /PUMP/.match(path) and not /tochk/.match(path) and not /TOCHECK/.match(path) and not /proofed\.by/.match(path) and not /pages$/.match(path) and not /!W61500B/.match(path) and not /README$/.match(path) and not /M63514W2/.match(path) and not /FULL\.NB3/.match(path) and not /FULLTEXT\.HTM/.match(path) and not /FULL@\.NB3/.match(path) and not /TRANS/.match(path) and not /NEWFULL\.RTF/.match(path) and not /TR$/.match(path) and not /ANOTHER/.match(path) and not /Z725740L/.match(path) and not /Smythe of Barbavilla\.doc/.match(path) and not /Y08B002H/.match(path) and not /Z787600L/.match(path) and not /SOURCES/.match(path) }.each do |file_path|

          expect {
              
            puts file_path
            
            @parser = SwiftPoetryProject::TeiParser.new "#{file_path}"
            @parser.parse.to_xml

            # puts @parser.parse.to_xml
          }.to_not raise_error
        end
      end

      it "parses all Nota Bene tokens within the document #{coll_path}" do

        Dir.glob("#{coll_path}/*").select {|path| not /tocheck/.match(path) and not /PUMP/.match(path) and not /tochk/.match(path) and not /TOCHECK/.match(path) and not /proofed\.by/.match(path) and not /pages$/.match(path) and not /!W61500B/.match(path) and not /README$/.match(path) and not /M63514W2/.match(path) and not /FULL\.NB3/.match(path) and not /FULLTEXT\.HTM/.match(path) and not /FULL@\.NB3/.match(path) and not /TRANS/.match(path) and not /NEWFULL\.RTF/.match(path) and not /TR$/.match(path) and not /ANOTHER/.match(path) and not /Z725740L/.match(path) and not /Smythe of Barbavilla\.doc/.match(path) and not /Y08B002H/.match(path) and not /Z787600L/.match(path) and not /SOURCES/.match(path) }.each do |file_path|

          expect {

            puts file_path

            @parser = SwiftPoetryProject::TeiParser.new "#{file_path}"
            results = @parser.parse.to_xml
            expect(results).not_to match(/«.+»/)
          }.to_not raise_error
        end
      end
    end
  end
end
