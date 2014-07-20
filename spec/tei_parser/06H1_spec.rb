require_relative '../spec_helper'

describe 'TeiParser' do

  before :each do

    @nb_store_path = '/usr/share/spp/ruby-tools/spp/master'
  end

  @nb_store_path = '/usr/share/spp/ruby-tools/spp/master'

  Dir.glob("#{@nb_store_path}/06H1/*").select {|path| not /tocheck/.match(path) and not /PUMP/.match(path) and not /tochk/.match(path) and not /TOCHECK/.match(path) and not /proofed\.by/.match(path) and not /pages$/.match(path) and not /!W61500B/.match(path) }.each do |file_path|

    it "parses the Nota Bene document #{file_path}" do

      expect {

        @parser = SwiftPoetryProject::TeiParser.new "#{file_path}"
        @parser.parse.to_xml
      }.to_not raise_error
    end
  end
end
