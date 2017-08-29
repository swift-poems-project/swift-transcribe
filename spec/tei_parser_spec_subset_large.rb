# -*- coding: utf-8 -*-

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

=begin
rspec ./spec/tei_parser_spec.rb[1:1:176:12:1] # TeiParser parsing all sources parsing the source /var/lib/spp/master/1601 excluding empty <l> or <p> elements preceding new <lg> elements generates TEI Documents with <l> or <p> elements bearing @n attribute values for the transcript /var/lib/spp/master/1601/S0321601
rspec ./spec/tei_parser_spec.rb[1:1:176:15:1] # TeiParser parsing all sources parsing the source /var/lib/spp/master/1601 excluding empty <l> or <p> elements preceding new <lg> elements generates TEI Documents with <l> or <p> elements bearing @n attribute values for the transcript /var/lib/spp/master/1601/X39D1601
rspec ./spec/tei_parser_spec.rb[1:1:176:18:1] # TeiParser parsing all sources parsing the source /var/lib/spp/master/1601 excluding empty <l> or <p> elements preceding new <lg> elements generates TEI Documents with <l> or <p> elements bearing @n attribute values for the transcript /var/lib/spp/master/1601/X38-1601
rspec ./spec/tei_parser_spec.rb[1:1:176:21:1] # TeiParser parsing all sources parsing the source /var/lib/spp/master/1601 excluding empty <l> or <p> elements preceding new <lg> elements generates TEI Documents with <l> or <p> elements bearing @n attribute values for the transcript /var/lib/spp/master/1601/X30B1601
rspec ./spec/tei_parser_spec.rb[1:1:176:24:1] # TeiParser parsing all sources parsing the source /var/lib/spp/master/1601 excluding empty <l> or <p> elements preceding new <lg> elements generates TEI Documents with <l> or <p> elements bearing @n attribute values for the transcript /var/lib/spp/master/1601/X31A1601
rspec ./spec/tei_parser_spec.rb[1:1:176:24:2] # TeiParser parsing all sources parsing the source /var/lib/spp/master/1601 excluding empty <l> or <p> elements preceding new <lg> elements generates TEI Documents with <l> or <p> elements bearing ordered, unique @n attribute values for the transcript /var/lib/spp/master/1601/X31A1601
rspec ./spec/tei_parser_spec.rb[1:1:177:135:2] # TeiParser parsing all sources parsing the source /var/lib/spp/master/35D- excluding empty <l> or <p> elements preceding new <lg> elements generates TEI Documents with <l> or <p> elements bearing ordered, unique @n attribute values for the transcript /var/lib/spp/master/35D-/610-35D-
rspec ./spec/tei_parser_spec.rb[1:1:177:291:2] # TeiParser parsing all sources parsing the source /var/lib/spp/master/35D- excluding empty <l> or <p> elements preceding new <lg> elements generates TEI Documents with <l> or <p> elements bearing ordered, unique @n attribute values for the transcript /var/lib/spp/master/35D-/640-35D-
rspec ./spec/tei_parser_spec.rb[1:1:177:342:2] # TeiParser parsing all sources parsing the source /var/lib/spp/master/35D- excluding empty <l> or <p> elements preceding new <lg> elements generates TEI Documents with <l> or <p> elements bearing ordered, unique @n attribute values for the transcript /var/lib/spp/master/35D-/811-35D-
rspec ./spec/tei_parser_spec.rb[1:1:178:1] # TeiParser parsing all sources parsing the source /var/lib/spp/master/530V parses the transcript /var/lib/spp/master/530V/!W59530V without error
rspec ./spec/tei_parser_spec.rb[1:1:178:2] # TeiParser parsing all sources parsing the source /var/lib/spp/master/530V parses all Nota Bene tokens within the transcript /var/lib/spp/master/530V/!W59530V
rspec ./spec/tei_parser_spec.rb[1:1:178:4] # TeiParser parsing all sources parsing the source /var/lib/spp/master/530V parses the transcript /var/lib/spp/master/530V/825-530V without error
rspec ./spec/tei_parser_spec.rb[1:1:178:5] # TeiParser parsing all sources parsing the source /var/lib/spp/master/530V parses all Nota Bene tokens within the transcript /var/lib/spp/master/530V/825-530V
rspec ./spec/tei_parser_spec.rb[1:1:178:7] # TeiParser parsing all sources parsing the source /var/lib/spp/master/530V parses the transcript /var/lib/spp/master/530V/X39C530V without error
rspec ./spec/tei_parser_spec.rb[1:1:178:8] # TeiParser parsing all sources parsing the source /var/lib/spp/master/530V parses all Nota Bene tokens within the transcript /var/lib/spp/master/530V/X39C530V
rspec ./spec/tei_parsrser parsing all sources parsingrsing all sources parsing the source /var/lib/spp/master/530V excluding empty <l> or <p> elements preceding new <lg> elements generates TEI Documents with <l> or <p> elements bearing @n attribute values for the transcript /var/lib/spthe transcript /var/lib/spp/master/530V/!W63530V
rspec ./spec/tei_parser_spec.rb[1:1:178:39:2] # TeiParpreceding new <lg> elements generates TEI Documents with <l> or <p> elements bearing ordered, unique @n attribute values for the transcript /var/lib/spp/master/530V/R544530V
rspec ./spec/tei_parser_spec.rb[1:1:183:48:2] # TeiParser parsing all sources parsing the source /var/lib/spp/master/700B excluding empty <l> or <p> elements preceding new <lg> elements generates TEI Documents with <l> or <p> elements bearing ordered, unique @n attribute values for the transcript /var/lib/spp/master/700B/427-700B
rspec ./spec/tei_parser_spec.rb[1:1:188:2] # TeiParser parsing all sources parsing the source /var/lib/spp/master/11M2 parses all Nota Bene tokens within the transcript /var/lib/spp/master/11M2/932-11M2
rspec ./spec/tei_parser_spec.rb[1:1:188:5] # TeiParser parsing all sources parsing the source /var/lib/spp/master/11M2 parses all Nota Bene tokens within the transcript /var/lib/spp/master/11M2/952C11M2
rspec ./spec/tei_parser_spec.rb[1:1:188:8] # TeiParser parsing all sources parsing the source /var/lib/spp/master/11M2 parses all Nota Bene tokens within the transcript /var/lib/spp/master/11M2/062-11M2
rspec ./spec/tei_parser_spec.rb[1:1:188:11] # TeiParser parsing all sources parsing the source /var/lib/spp/master/11M2 parses all Nota Bene tokens within the transcript /var/lib/spp/master/11M2/929A11M2
rspec ./spec/tei_parser_spec.rb[1:1:188:14] # TeiParser parsing all sources parsing the source /var/lib/spp/master/11M2 parsees all Nota Bene tokens within the transcript /var/lib/spp/master/11M2/673A11M2
rspec ./spec/tei_parser_spec.rb[1:1:188:56] # TeiPars
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
         ]

        [
         '/var/lib/spp/master/0801/553-0801',
#         '/var/lib/spp/master/27L3/M12527L3',
         
        ].each do |file_path|

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
                indices = l_elements.select { |element| element.has_attribute? 'n' }.map { |element| element['n'] }.select { |index| not /\d+[a-z]$/.match(index) }

                unless indices.empty?

                  sorted_indices = indices.map { |index| index.to_i }.sort
                  indices = indices.map { |index| index.to_i }

                  valid_range = (sorted_indices.first..sorted_indices.last)

                  expect(indices).to eq(valid_range.to_a)
                end
                
                p_elements = tei_doc.xpath('//TEI:body/TEI:div/TEI:div/TEI:lg/TEI:p', 'TEI' => 'http://www.tei-c.org/ns/1.0')
                indices = p_elements.select { |element| element.has_attribute? 'n' }.map { |element| element['n'] }.select { |index| not /\d+[a-z]$/.match(index) }
                
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

