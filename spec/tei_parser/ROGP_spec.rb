# -*- coding: utf-8 -*-

require_relative '../spec_helper'

describe 'TeiParser' do

  before :each do

    @nb_store_path = '/var/lib/spp/master'
  end

  describe 'parsing all sources' do

    source = 'ROGP'
    source_dir = File.join(File.dirname(__FILE__), '../../xml', source)
    @nb_store_path = '/var/lib/spp/master'

    coll_path = "#{@nb_store_path}/#{source}"
    Dir.glob("#{coll_path}/*").each_index do |file_index|
#    [0].each_index do |file_index|

      describe "parsing the source #{coll_path}" do

        [ Dir.glob("#{coll_path}/*")[file_index] ].each do |file_path|
#        [ "/var/lib/spp/master/11M1/601-11M1" ].each do |file_path|
          
          before :each do

            @parser = SwiftPoetryProject::TeiParser.new "#{file_path}"
          end

          after :each do

            @parser = SwiftPoetryProject::TeiParser.new "#{file_path}"
            @results = @parser.parse.to_xml
            Dir.mkdir source_dir unless Dir.exist? source_dir
            File.open(File.join(source_dir, "#{File.basename(file_path)}.tei.xml"), 'w') {|f| f.write @results }
          end

          it "parses the transcript #{file_path} without error" do

            expect {

              @results = @parser.parse.to_xml
              puts @results
            }.to_not raise_error
          end

          it "parses all Nota Bene tokens within the transcript #{file_path}" do

            results = @parser.parse.to_xml

            expect(results).not_to match(/«.+»/)
            expect(results).not_to match(/\|/)
          end

          context "excluding empty <l> or <p> elements preceding new <lg> elements" do

            it "generates TEI Documents with <l> or <p> elements bearing @n attribute values for the transcript #{file_path}" do

              expect {

                tei_doc = @parser.parse

                l_elements = tei_doc.xpath('//TEI:lg[@type="stanza" or @type="verse-paragraph" or @type="triplet"]/TEI:l', 'TEI' => 'http://www.tei-c.org/ns/1.0')
                invalid_elements = l_elements.select { |element| not element.has_attribute? 'n' and not element.next_element.nil? and not /\-a$/.match(element['xml:id']) }.map { |element| element.to_xml }
                expect(invalid_elements).to be_empty
              }.to_not raise_error
            end

            it "generates TEI Documents with <l> or <p> elements bearing ordered, unique @n attribute values for the transcript #{file_path}" do

              expect {

                tei_doc = @parser.parse
#                puts tei_doc.to_xml

                l_elements = tei_doc.xpath('//TEI:lg[@type="stanza" or @type="verse-paragraph" or @type="triplet"]/TEI:l', 'TEI' => 'http://www.tei-c.org/ns/1.0')
                indices = l_elements.select { |element| element.has_attribute? 'n' }.map { |element| element['n'] }.select { |index| not /\d+[a-z]$/.match(index) }

                unless indices.empty?

                  sorted_indices = indices.map { |index| index.to_i }.sort
                  indices = indices.map { |index| index.to_i }

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

