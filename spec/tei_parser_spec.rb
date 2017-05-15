# -*- coding: utf-8 -*-

require_relative 'spec_helper'

describe 'TeiParser' do

  before :each do

    @nb_store_path = '/var/lib/spp/master'
  end

  describe 'parsing all sources' do
    
    @nb_store_path = '/var/lib/spp/master'

    Dir.glob("#{@nb_store_path}/*").select {|path| not /TEI-samp/.match path and not /BIBLS/.match path and not /CASE/.match path and not /PRSOURCE/.match path and not /MSSOURCE/.match path  and not /EDIT/.match path  and not /DESCRIBE/.match path and not /4DOS750/.match path and not /HW37/.match path and not /XML-Test/.match path and not /incoming/.match path and not /POEMCOLL/.match path and not /NB/.match path and not /NEWDOS/.match path and not /INSTALL/.match path and not /FAULKNER/.match path and not /STEMMAS/.match path and not /FAIRBROT/.match path and not /INV/.match path }.each do |coll_path|

      describe "parsing the source #{coll_path}" do

        Dir.glob("#{coll_path}/*").select {|path| not /tocheck/.match(path) and not /PUMP/.match(path) and not /tochk/.match(path) and not /TOCHECK/.match(path) and not /proofed\.by/.match(path) and not /pages$/.match(path) and not /!W61500B/.match(path) and not /README$/.match(path) and not /M63514W2/.match(path) and not /FULL\.NB3/.match(path) and not /FULLTEXT\.HTM/.match(path) and not /FULL@\.NB3/.match(path) and not /TRANS/.match(path) and not /NEWFULL\.RTF/.match(path) and not /TR$/.match(path) and not /ANOTHER/.match(path) and not /Z725740L/.match(path) and not /Smythe of Barbavilla\.doc/.match(path) and not /Y08B002H/.match(path) and not /SOURCES/.match(path) and path != "#{@nb_store_path}/600L/Z786600L" and path != "#{@nb_store_path}/600L/Z787600L" }.each do |file_path|

=begin

    ['test'].each do |coll_path|

      describe "parsing the source #{coll_path}" do

[
'/var/lib/spp/master/0202/365-0202',
'/var/lib/spp/master/090A/365-090A',
'/var/lib/spp/master/05P4/365-05P4',
'/var/lib/spp/master/0204/365-0204',
'/var/lib/spp/master/0251/365-0251',
'/var/lib/spp/master/07H1/365-07H1',
'/var/lib/spp/master/WILH/365-WILH',
'/var/lib/spp/master/0201/365-0201',
'/var/lib/spp/master/05P2/365-05P2',
'/var/lib/spp/master/0253/365-0253',
'/var/lib/spp/master/0252/365-0252',
'/var/lib/spp/master/14W2/365-14W2',
'/var/lib/spp/master/05M2/365-05M2',
'/var/lib/spp/master/36L-/365-36L-',
'/var/lib/spp/master/06E2/365-06E2',
'/var/lib/spp/master/05M1/365-05M1',
'/var/lib/spp/master/35D-/365-35D-',
'/var/lib/spp/master/05P1/365-05P1',
'/var/lib/spp/master/200I/365-200I',
'/var/lib/spp/master/0254/365-0254',
'/var/lib/spp/master/79L1/365-79L1',
'/var/lib/spp/master/0271/365-0271',
'/var/lib/spp/master/0203/365-0203',
'/var/lib/spp/master/200I/365-200I'

].each do |file_path|
=end

          before :each do

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

          context "excluding empty <l> or <p> elements preceding new <lg> elements" do

            it "generates TEI Documents with <l> or <p> elements bearing @n attribute values for the transcript #{file_path}" do

              expect {

                tei_doc = @parser.parse

                l_elements = tei_doc.xpath('//TEI:l', 'TEI' => 'http://www.tei-c.org/ns/1.0')
                invalid_elements = l_elements.select { |element| not element.has_attribute? 'n' and not element.next_element.nil? }.map { |element| element.to_xml }
                expect(invalid_elements).to be_empty

                p_elements = tei_doc.xpath('//TEI:body/TEI:div/TEI:div/TEI:lg/TEI:p', 'TEI' => 'http://www.tei-c.org/ns/1.0')
                invalid_elements = p_elements.select { |element| not element.has_attribute? 'n' and not element.next_element.nil? }.map { |element| element.to_xml }
                expect(invalid_elements).to be_empty
              
              }.to_not raise_error
            end

            it "generates TEI Documents with <l> or <p> elements bearing ordered, unique @n attribute values for the transcript #{file_path}" do

              expect {

                @parser = SwiftPoetryProject::TeiParser.new "#{file_path}"
                tei_doc = @parser.parse

                # puts tei_doc.to_xml

                l_elements = tei_doc.xpath('//TEI:l', 'TEI' => 'http://www.tei-c.org/ns/1.0')
                indices = l_elements.select { |element| element.has_attribute? 'n' }.map { |element| element['n'].to_i }

                unless indices.empty?
                  
                  sorted_indices = indices.sort
                  valid_range = (sorted_indices.first..sorted_indices.last)

                  expect(indices).to eq(valid_range.to_a)
                end
                
                p_elements = tei_doc.xpath('//TEI:body/TEI:div/TEI:div/TEI:lg/TEI:p', 'TEI' => 'http://www.tei-c.org/ns/1.0')
                indices = p_elements.select { |element| element.has_attribute? 'n' }.map { |element| element['n'].to_i }
                
                unless indices.empty?
                  
                  sorted_indices = indices.sort
                  valid_range = (sorted_indices.first..sorted_indices.last)
                  
                  expect(indices).to eq(valid_range.to_a)
                end
              }.to_not raise_error
            end
          end
        end
      end
    end
  end
end
