# -*- coding: utf-8 -*-

require_relative '../spec_helper'

describe 'TeiParser' do

  before :each do

    @nb_store_path = '/var/lib/spp/master'
  end

  describe 'parsing all sources' do

    source = '05P1'
    source_dir = File.join(File.dirname(__FILE__), '../../xml', source)
    @nb_store_path = '/var/lib/spp/master'

    coll_path = "#{@nb_store_path}/#{source}"
    Dir.glob("#{coll_path}/*").each_index do |file_index|
#    [0].each_index do |file_index|

      describe "parsing the source #{coll_path}" do

        [ Dir.glob("#{coll_path}/*")[file_index] ].each do |file_path|
#        [ "/var/lib/spp/master/06E2/366-06E2" ].each do |file_path|
          
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

              puts results
            end
          end
        end
      end
    end
  end
end
