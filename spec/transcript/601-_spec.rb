# -*- coding: utf-8 -*-

require_relative '../spec_helper'

describe 'Transcript' do
  describe "#initialize" do
    @file_paths = [
'/var/lib/spp/master/0801/601-0801',
'/var/lib/spp/master/11M1/601-11M1',
'/var/lib/spp/master/ROGP/601-ROGP',
'/var/lib/spp/master/07G1/601-07G1',
'/var/lib/spp/master/79L2/601-79L2',
'/var/lib/spp/master/07H1/601-07H1',
'/var/lib/spp/master/71H1/601-71H1',
'/var/lib/spp/master/WILH/601-WILH',
'/var/lib/spp/master/0853/601-0853',
'/var/lib/spp/master/14W2/601-14W2',
'/var/lib/spp/master/083Y/601-083Y',
'/var/lib/spp/master/TRANSCRI/601-61L3',
'/var/lib/spp/master/FOXON/601-S808',
'/var/lib/spp/master/FOXON/601-S804',
'/var/lib/spp/master/FOXON/601-S806',
'/var/lib/spp/master/11M2/601-11M2',
'/var/lib/spp/master/0802/601-0802',
'/var/lib/spp/master/46L-/601-46L-',
'/var/lib/spp/master/07E2/601-07E2',
'/var/lib/spp/master/0271/601-0271',
'/var/lib/spp/master/0852/601-0852',
'/var/lib/spp/master/0851/601-0851']

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
