# -*- coding: utf-8 -*-

require_relative '../spec_helper'

describe 'Transcript' do
  describe "#initialize" do
    @file_paths = ['/var/lib/spp/master/0202/425-0202',
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
                   '/var/lib/spp/master/0203/425-0203']

    @file_paths.each do |file_path|

      before :each do
        @nota_bene = SwiftPoemsProject::NotaBene::Document.new file_path
      end

      it "parses the transcript #{file_path} without error" do
        expect {
          transcript = SwiftPoemsProject::Transcript.new @nota_bene
        }.to_not raise_error
      end

      context "ensuring that the transcripts can be encoded" do

        before :each do
          @transcript = SwiftPoemsProject::Transcript.new @nota_bene
        end
        
        it "parses all Nota Bene tokens within the transcript #{file_path}" do
          results = @transcript.tei.document.to_xml
          
          expect(results).not_to match(/«.+»/)
          expect(results).not_to match(/\|/)
        end
        
        it "generates TEI Documents with <l> or <p> elements bearing ordered, unique @n attribute values for the transcript #{file_path}" do
          expect {
            tei_doc = @transcript.tei.document
            
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
