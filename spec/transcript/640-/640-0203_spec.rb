# -*- coding: utf-8 -*-

require_relative '../../spec_helper'

describe 'Transcript' do
  describe "#initialize" do
    file_path = '/var/lib/spp/master/0203/640-0203'

 
      source = file_path.split('/')[-2]
      source_dir = File.join(File.dirname(__FILE__), '../../../xml', source)

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
