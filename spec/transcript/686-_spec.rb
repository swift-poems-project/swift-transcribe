# -*- coding: utf-8 -*-

require_relative '../spec_helper'

describe 'Transcript' do
  describe "#initialize" do
    @file_paths = [
                   '/var/lib/spp/master/35X1/686-35X1',
                   '/var/lib/spp/master/422R/686-422R',
                   '/var/lib/spp/master/0202/686-0202',
                   '/var/lib/spp/master/ROGP/686-ROGP',
                   '/var/lib/spp/master/0204/686-0204',
                   '/var/lib/spp/master/03P3/686-03P3',
                   '/var/lib/spp/master/0251/686-0251',
                   '/var/lib/spp/master/59L2/686-59L2',
                   '/var/lib/spp/master/03P5/686-03P5',
                   '/var/lib/spp/master/MSS/686-308F',
                   '/var/lib/spp/master/MSS/686-546Y',
                   '/var/lib/spp/master/MSS/686-186Y',
                   '/var/lib/spp/master/MSS/686-150B',
                   '/var/lib/spp/master/28D-/686-28D-',
                   '/var/lib/spp/master/03P4/686-03P4',
                   '/var/lib/spp/master/WILH/686-WILH',
                   '/var/lib/spp/master/0201/686-0201',
                   '/var/lib/spp/master/72H1/686-72H1',
                   '/var/lib/spp/master/32D-/686-32D-',
                   '/var/lib/spp/master/0253/686-0253',
                   '/var/lib/spp/master/0252/686-0252',
                   '/var/lib/spp/master/03P1/686-03P1',
                   '/var/lib/spp/master/14W2/686-14W2',
                   '/var/lib/spp/master/TRANSCRI/686-33L9',
                   '/var/lib/spp/master/TRANSCRI/686-35LA',
                   '/var/lib/spp/master/TRANSCRI/686-28L5',
                   '/var/lib/spp/master/TRANSCRI/686-26XF',
                   '/var/lib/spp/master/TRANSCRI/686-27L1',
                   '/var/lib/spp/master/TRANSCRI/686-26OG',
                   '/var/lib/spp/master/TRANSCRI/686-31L1',
                   '/var/lib/spp/master/17H2/686-17H2',
                   '/var/lib/spp/master/36L-/686-36L-',
                   '/var/lib/spp/master/06E2/686-06E2',
                   '/var/lib/spp/master/FOXON/686-S829',
                   '/var/lib/spp/master/FOXON/686-S818',
                   '/var/lib/spp/master/FOXON/686-S819',
                   '/var/lib/spp/master/FOXON/686-S817',
                   '/var/lib/spp/master/FOXON/686-S827',
                   '/var/lib/spp/master/FOXON/686-S822',
                   '/var/lib/spp/master/FOXON/686-S820',
                   '/var/lib/spp/master/FOXON/686-S814',
                   '/var/lib/spp/master/FOXON/686-S825',
                   '/var/lib/spp/master/FOXON/686-S826',
                   '/var/lib/spp/master/FOXON/686-S815',
                   '/var/lib/spp/master/FOXON/686-S816',
                   '/var/lib/spp/master/600I/686-600I',
                   '/var/lib/spp/master/04M1/686-04M1',
                   '/var/lib/spp/master/700B/686-700B',
                   '/var/lib/spp/master/06H1/686-06H1',
                   '/var/lib/spp/master/020B/686-020B',
                   '/var/lib/spp/master/03P7/686-03P7',
                   '/var/lib/spp/master/28L-/686-28L-',
                   '/var/lib/spp/master/0254/686-0254',
                   '/var/lib/spp/master/79L1/686-79L1',
                   '/var/lib/spp/master/54B-/686-54B-',
                   '/var/lib/spp/master/0271/686-0271',
                   '/var/lib/spp/master/03P2/686-03P2',
                   '/var/lib/spp/master/600B/686-600B',
                   '/var/lib/spp/master/0203/686-0203',
                   '/var/lib/spp/master/04M2/686-04M2']

    @file_paths.each do |file_path|
      source = file_path.split('/')[-2]
      source_dir = File.join(File.dirname(__FILE__), '../../xml', source)

      before :each do
        @nota_bene = SwiftPoemsProject::NotaBene::Document.new file_path
      end

      after :all do
        nota_bene = SwiftPoemsProject::NotaBene::Document.new file_path
        transcript = SwiftPoemsProject::Transcript.new nota_bene
        output = transcript.tei.document.to_xml
        Dir.mkdir source_dir unless Dir.exist? source_dir
        File.open(File.join(source_dir, "#{File.basename(file_path)}.tei.xml"), 'w') {|f| f.write output }
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
