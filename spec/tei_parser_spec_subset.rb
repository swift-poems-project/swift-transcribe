# -*- coding: utf-8 -*-

require_relative 'spec_helper'

describe 'TeiParser' do

  before :each do

    @nb_store_path = '/var/lib/spp/master'
  end

  describe 'parsing all sources' do
    
    @nb_store_path = '/var/lib/spp/master'

    ['test'].each do |coll_path|

      describe "parsing the source #{coll_path}" do

=begin

rspec ./spec/tei_parser_spec_subset.rb[1:1:1:6:2] # TeiParser parsing all sources parsing the source test excluding empty <l> or <p> elements preceding new <lg> elements generates TEI Documents with <l> or <p> elements bearing ordered, unique @n attribute values for the transcript /var/lib/spp/master/0801/553-0801
rspec ./spec/tei_parser_spec_subset.rb[1:1:1:24:2] # TeiParser parsing all sources parsing the source test excluding empty <l> or <p> elements preceding new <lg> elements generates TEI Documents with <l> or <p> elements bearing ordered, unique @n attribute values for the transcript /var/lib/spp/master/27L3/M12527L3
rspec ./spec/tei_parser_spec_subset.rb[1:1:1:33:2] # TeiParser parsing all sources parsing the source test excluding empty <l> or <p> elements preceding new <lg> elements generates TEI Documents with <l> or <p> elements bearing ordered, unique @n attribute values for the transcript /var/lib/spp/master/27L3/M12527L3

=end

        [
         '/var/lib/spp/master/0801/X13-0801',
         '/var/lib/spp/master/0801/553-0801',
         '/var/lib/spp/master/27L3/915-27L3',
         '/var/lib/spp/master/27L3/341-27L3',
         '/var/lib/spp/master/27L3/M11227L3',
         '/var/lib/spp/master/27L3/M11027L3',
         '/var/lib/spp/master/27L3/Y25-27L3',
         '/var/lib/spp/master/27L3/M12527L3',
         '/var/lib/spp/master/27L3/Y09C27L3',
         '/var/lib/spp/master/27L3/341-27L3',
         '/var/lib/spp/master/27L3/M12527L3',
         '/var/lib/spp/master/06G1/207-06G1',
         '/var/lib/spp/master/0801/553-0801',
         '/var/lib/spp/master/06G1/207-06G1',
         '/var/lib/spp/master/0801/X13-0801',
         '/var/lib/spp/master/27L3/M12527L3',
        ]

        [
'/var/lib/spp/master/0202/425-0202',
'/var/lib/spp/master/05P4/425-05P4',
'/var/lib/spp/master/ROGP/425-ROGP',
'/var/lib/spp/master/0204/425-0204',
'/var/lib/spp/master/0251/425-0251',
'/var/lib/spp/master/79L2/425-79L2',
'/var/lib/spp/master/07H1/425-07H1',
'/var/lib/spp/master/WILH/425-WILH',
'/var/lib/spp/master/0201/425-0201',
'/var/lib/spp/master/05P2/425-05P2',
'/var/lib/spp/master/0253/425-0253',
'/var/lib/spp/master/0252/425-0252',
'/var/lib/spp/master/102M/425-102M',
'/var/lib/spp/master/05M2/425-05M2',
'/var/lib/spp/master/36L-/425-36L-',
'/var/lib/spp/master/06E2/425-06E2',
'/var/lib/spp/master/05M1/425-05M1',
'/var/lib/spp/master/600I/425-600I',
'/var/lib/spp/master/35D-/425-35D-',
'/var/lib/spp/master/700B/425-700B',
'/var/lib/spp/master/05P1/425-05P1',
'/var/lib/spp/master/001B/425-001B',
'/var/lib/spp/master/0254/425-0254',
'/var/lib/spp/master/0271/425-0271',
'/var/lib/spp/master/0203/425-0203'
        ]

        [
'/var/lib/spp/master/001B/156-001B',
'/var/lib/spp/master/001B/160-001B',
'/var/lib/spp/master/001B/162-001B',
'/var/lib/spp/master/001B/170-001B',
'/var/lib/spp/master/001B/198-001B',
'/var/lib/spp/master/001B/219-001B',
'/var/lib/spp/master/001B/222-001B',
'/var/lib/spp/master/001B/226-001B',
'/var/lib/spp/master/001B/239-001B',
'/var/lib/spp/master/001B/250-001B',
'/var/lib/spp/master/001B/263-001B',
'/var/lib/spp/master/001B/274-001B',
'/var/lib/spp/master/001B/327-001B',
'/var/lib/spp/master/001B/328A001B',
'/var/lib/spp/master/001B/328B001B',
'/var/lib/spp/master/001B/425-001B',
'/var/lib/spp/master/001B/721-001B',
'/var/lib/spp/master/001B/734-001B',
'/var/lib/spp/master/001B/739B001B',
#        ]

=begin
        [
         #'/var/lib/spp/master/001B/156-001B',
         #'/var/lib/spp/master/001B/170-001B',
         #'/var/lib/spp/master/001B/263-001B',
         # '/var/lib/spp/master/001B/328A001B',
         #'/var/lib/spp/master/001B/198-001B',
         #'/var/lib/spp/master/001B/425-001B',
         #'/var/lib/spp/master/001B/739B001B',
         #'/var/lib/spp/master/001D/809-001D',
         #'/var/lib/spp/master/002H/302-002H',
         #'/var/lib/spp/master/002H/807-002H',
         '/var/lib/spp/master/002H/811-002H',
=end
        ].each do |file_path|

          before :each do

            @parser = SwiftPoetryProject::TeiParser.new "#{file_path}"
          end

          after :each do

            @parser = SwiftPoetryProject::TeiParser.new "#{file_path}"
            @results = @parser.parse.to_xml
            File.open("/home/griffinj/python.d/swift-diff/tests/fixtures/425/#{File.basename(file_path)}.tei.xml", 'w') {|f| f.write @results }
          end

          it "parses the transcript #{file_path} without error" do

            expect {

              @results = @parser.parse.to_xml
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

                l_elements = tei_doc.xpath('//TEI:lg[@type="stanza" or @type="verse-paragraph"]/TEI:l', 'TEI' => 'http://www.tei-c.org/ns/1.0')
                invalid_elements = l_elements.select { |element| not element.has_attribute? 'n' and not element.next_element.nil? }.map { |element| element.to_xml }
                expect(invalid_elements).to be_empty

#                p_elements = tei_doc.xpath('//TEI:body/TEI:div/TEI:div/TEI:lg/TEI:p', 'TEI' => 'http://www.tei-c.org/ns/1.0')
#                invalid_elements = p_elements.select { |element| not element.has_attribute? 'n' and not element.next_element.nil? }.map { |element| element.to_xml }
#                expect(invalid_elements).to be_empty
              
              }.to_not raise_error
            end

            it "generates TEI Documents with <l> or <p> elements bearing ordered, unique @n attribute values for the transcript #{file_path}" do

              expect {

                tei_doc = @parser.parse

                l_elements = tei_doc.xpath('//TEI:lg[@type="stanza" or @type="verse-paragraph"]/TEI:l', 'TEI' => 'http://www.tei-c.org/ns/1.0')
                indices = l_elements.select { |element| element.has_attribute? 'n' }.map { |element| element['n'] }.select { |index| not /\d+[a-z]$/.match(index) }

                unless indices.empty?

                  sorted_indices = indices.map { |index| index.to_i }.sort
                  indices = indices.map { |index| index.to_i }

                  valid_range = (sorted_indices.first..sorted_indices.last)

                  expect(indices).to eq(valid_range.to_a)
                end
                
#                p_elements = tei_doc.xpath('//TEI:body/TEI:div/TEI:div/TEI:lg/TEI:p', 'TEI' => 'http://www.tei-c.org/ns/1.0')
#                indices = p_elements.select { |element| element.has_attribute? 'n' }.map { |element| element['n'] }.select { |index| not /\d+[a-z]$/.match(index) }
                
#                unless indices.empty?
                  
#                  sorted_indices = indices.map { |index| index.to_i }.sort
#                  indices = indices.map { |index| index.to_i }

#                  valid_range = (sorted_indices.first..sorted_indices.last)
                  
#                  expect(indices).to eq(valid_range.to_a)
#                end
              }.to_not raise_error
            end
          end
        end
      end
    end
  end
end

