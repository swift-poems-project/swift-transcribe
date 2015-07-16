# -*- coding: utf-8 -*-

require_relative 'spec_helper'

describe 'TeiParser' do

  before :each do

    @nb_store_path = '/var/lib/spp/master'
  end

  describe 'parsing all sources' do
    
    @nb_store_path = '/var/lib/spp/master'

=begin
    Dir.glob("#{@nb_store_path}/*").select {|path| not /TEI-samp/.match path and not /BIBLS/.match path and not /CASE/.match path and not /PRSOURCE/.match path and not /MSSOURCE/.match path  and not /EDIT/.match path  and not /DESCRIBE/.match path and not /4DOS750/.match path and not /HW37/.match path and not /XML-Test/.match path and not /incoming/.match path and not /POEMCOLL/.match path and not /NB/.match path and not /NEWDOS/.match path and not /INSTALL/.match path and not /FAULKNER/.match path and not /STEMMAS/.match path and not /FAIRBROT/.match path and not /INV/.match path }.each do |coll_path|

      describe "parsing the source #{coll_path}" do

        Dir.glob("#{coll_path}/*").select {|path| not /tocheck/.match(path) and not /PUMP/.match(path) and not /tochk/.match(path) and not /TOCHECK/.match(path) and not /proofed\.by/.match(path) and not /pages$/.match(path) and not /!W61500B/.match(path) and not /README$/.match(path) and not /M63514W2/.match(path) and not /FULL\.NB3/.match(path) and not /FULLTEXT\.HTM/.match(path) and not /FULL@\.NB3/.match(path) and not /TRANS/.match(path) and not /NEWFULL\.RTF/.match(path) and not /TR$/.match(path) and not /ANOTHER/.match(path) and not /Z725740L/.match(path) and not /Smythe of Barbavilla\.doc/.match(path) and not /Y08B002H/.match(path) and not /SOURCES/.match(path) and path != "#{@nb_store_path}/600L/Z786600L" and path != "#{@nb_store_path}/600L/Z787600L" }.each do |file_path|
=end

    ['test'].each do |coll_path|

      describe "parsing the source #{coll_path}" do

        ['/var/lib/spp/master/200I/365-200I'].each do |file_path|

          before :all do

            @parser = SwiftPoetryProject::TeiParser.new "#{file_path}"
          end

          it "parses the transcript #{file_path} without error" do

            expect {

              results = @parser.parse.to_xml
            }.to_not raise_error
          end

          it "parses all Nota Bene tokens within the transcript #{file_path}" do

            results = @parser.parse.to_xml

            expect(results).not_to match(/«.+»/)
          end

          it "generates TEI Documents with <l> or <p> elements bearing @n attribute values for the transcript #{file_path}" do

            tei_doc = @parser.parse

            puts tei_doc.to_xml

            l_elements = tei_doc.xpath('//TEI:l', 'TEI' => 'http://www.tei-c.org/ns/1.0')
            invalid_elements = l_elements.select { |element| not element.has_attribute? 'n' or element['n'].empty? }.map { |element| element.to_xml }
            expect(invalid_elements).to be_empty

            p_elements = tei_doc.xpath('//TEI:body/TEI:div/TEI:div/TEI:lg/TEI:p', 'TEI' => 'http://www.tei-c.org/ns/1.0')
            invalid_elements = p_elements.select { |element| not element.has_attribute? 'n' or element['n'].empty? }.map { |element| element.to_xml }
            expect(invalid_elements).to be_empty
          end
        end
      end
    end
  end
end
