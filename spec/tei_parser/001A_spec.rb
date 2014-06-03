
require_relative '../spec_helper'

describe 'TeiParser' do

  before :each do

    @nb_store_path = '/usr/share/spp/ruby-tools/spp/master'
  end

  describe 'collection parsing' do

    @nb_store_path = '/usr/share/spp/ruby-tools/spp/master'

    Dir.glob("#{@nb_store_path}/*").each do |coll_path|
      
      it "parses all Nota Bene documents within the collection #{coll_path}" do

        @nb_store_path = '/usr/share/spp/ruby-tools/spp/master'

        Dir.glob("#{coll_path}/*").select { |path| not /'578\-MISC'/.match(path) and not /'TRANSCRI'/.match(path) and not /'FOXON'/.match(path) }.each do |file_path|

          expect {

            @parser = SwiftPoetryProject::TeiParser.new "#{file_path}"
            @parser.parse.to_xml
          }.to_not raise_error
        end
      end
    end
  end
end
