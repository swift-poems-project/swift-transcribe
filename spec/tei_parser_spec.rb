
require_relative 'spec_helper'

describe 'TeiParser' do

  before :each do

    @nb_store_path = '/usr/share/spp/ruby-tools/spp/master'
  end

  describe 'collection parsing' do

    @nb_store_path = '/usr/share/spp/ruby-tools/spp/master'

    Dir.glob("#{@nb_store_path}/*").each do |coll_path|
      
      it "parses all Nota Bene documents within the collection #{coll_path}" do

        @nb_store_path = '/usr/share/spp/ruby-tools/spp/master'

#        Dir.glob("#{coll_path}/*").select { |path|
#          not path['578-MISC'] and not path['TRANSCRI'] and not path['FOXON'] and not path['PUMP'] and not path['ANOTHER'] and not path['tocheck'] and not path['WILH'] and not path['Smythe of Barbavilla.doc'] and not path['tochk']
#        }.each do |file_path|
        Dir.glob("#{coll_path}/*").select {|path| not /tocheck/.match(path) and not /PUMP/.match(path) and not /tochk/.match(path) and not /TOCHECK/.match(path) and not /proofed\.by/.match(path) and not /pages$/.match(path) and not /!W61500B/.match(path) and not /README$/.match(path) and not /M63514W2/.match(path) and not /FULL\.NB3/.match(path) and not /FULLTEXT\.HTM/.match(path) and not /FULL@\.NB3/.match(path)and not /TRANS/.match(path) and not /NEWFULL\.RTF/.match(path) and not /TR$/.match(path) and not /ANOTHER/.match(path) and not /Z725740L/.match(path) and not /Smythe of Barbavilla\.doc/.match(path) }.each do |file_path|

          expect {

            @parser = SwiftPoetryProject::TeiParser.new "#{file_path}"
            @parser.parse.to_xml
          }.to_not raise_error
        end
      end
    end
  end
end
