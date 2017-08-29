# -*- coding: utf-8 -*-

require_relative '../spec_helper'

describe 'Transcript' do
  describe "#initialize" do
    @file_paths = [
                   '/var/lib/spp/master/0202/640-0202',
                   '/var/lib/spp/master/090A/640-090A',
                   '/var/lib/spp/master/05P4/640-05P4',
                   '/var/lib/spp/master/ROGP/640-ROGP',
                   '/var/lib/spp/master/0204/640-0204',
                   '/var/lib/spp/master/07G1/640-07G1',
                   '/var/lib/spp/master/0251/640-0251',
                   '/var/lib/spp/master/79L2/640-79L2',
                   '/var/lib/spp/master/07H1/640-07H1',
                   '/var/lib/spp/master/MSS/640-002M',
                   '/var/lib/spp/master/MSS/640-901O',
                   '/var/lib/spp/master/MSS/640-901Y',
                   '/var/lib/spp/master/MSS/640-034Q',
                   '/var/lib/spp/master/MSS/640-492A',
                   '/var/lib/spp/master/MSS/640-001H',
                   '/var/lib/spp/master/MSS/640-452A',
                   '/var/lib/spp/master/MSS/640-300C',
                   '/var/lib/spp/master/MSS/640-901A',
                   '/var/lib/spp/master/MSS/640-501A',
                   '/var/lib/spp/master/WILH/640-WILH',
                   '/var/lib/spp/master/0201/640-0201',
                   '/var/lib/spp/master/05P2/640-05P2',
                   '/var/lib/spp/master/003K/640-003K',
                   '/var/lib/spp/master/0253/640-0253',
                   '/var/lib/spp/master/0252/640-0252',
                   '/var/lib/spp/master/14W2/640-14W2',
                   '/var/lib/spp/master/05M2/640-05M2',
                   '/var/lib/spp/master/TRANSCRI/640-14W1',
                   '/var/lib/spp/master/TRANSCRI/640-60D1',
                   '/var/lib/spp/master/TRANSCRI/640-34L2',
                   '/var/lib/spp/master/TRANSCRI/640-#6ZA',
                   '/var/lib/spp/master/36L-/640-36L-',
                   '/var/lib/spp/master/05M1/640-05M1',
                   '/var/lib/spp/master/FOXON/640-S888',
                   '/var/lib/spp/master/FOXON/640-S890',
                   '/var/lib/spp/master/FOXON/640-S889',
                   '/var/lib/spp/master/161O/640-161O',
                   '/var/lib/spp/master/600I/640-600I',
                   '/var/lib/spp/master/35D-/640-35D-',
                   '/var/lib/spp/master/05P1/640-05P1',
                   '/var/lib/spp/master/0254/640-0254',
                   '/var/lib/spp/master/1071/640-1071',
                   '/var/lib/spp/master/07E2/640-07E2',
                   '/var/lib/spp/master/0203/640-0203']    

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
