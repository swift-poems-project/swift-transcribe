# -*- coding: utf-8 -*-
require_relative '../spec_helper'

describe 'TeiParser' do

  before :each do

    @nb_store_path = '/var/lib/spp/master'
  end

  @nb_store_path = '/var/lib/spp/master'

  '609-031Q'
  '250-515B'
  '408-110H'
  
  Dir.glob("#{@nb_store_path}/MSS/*").select {|path| not /tocheck/.match(path) and not /PUMP/.match(path) and not /tochk/.match(path) and not /TOCHECK/.match(path) and not /proofed\.by/.match(path) and not /pages$/.match(path) and not /!W61500B/.match(path) and not /README$/.match(path) and not /M63514W2/.match(path) and not /FULL\.NB3/.match(path) and not /FULLTEXT\.HTM/.match(path) and not /FULL@\.NB3/.match(path)and not /TRANS/.match(path) and not /NEWFULL\.RTF/.match(path) and not /TR$/.match(path) and not /ANOTHER/.match(path) and not /Y08B002H/.match(path) }.each do |file_path|
  # Dir.glob("#{@nb_store_path}/MSS/609-031Q").select {|path| not /tocheck/.match(path) and not /PUMP/.match(path) and not /tochk/.match(path) and not /TOCHECK/.match(path) and not /proofed\.by/.match(path) and not /pages$/.match(path) and not /!W61500B/.match(path) and not /README$/.match(path) and not /M63514W2/.match(path) and not /FULL\.NB3/.match(path) and not /FULLTEXT\.HTM/.match(path) and not /FULL@\.NB3/.match(path)and not /TRANS/.match(path) and not /NEWFULL\.RTF/.match(path) and not /TR$/.match(path) and not /ANOTHER/.match(path) and not /Y08B002H/.match(path) }.each do |file_path|

    it "parses the Nota Bene document #{file_path}" do

      expect {
        
        @parser = SwiftPoetryProject::TeiParser.new "#{file_path}"
        @parser.parse.to_xml
      }.to_not raise_error
    end

    it "parses the Nota Bene document #{file_path}" do
      
      expect {

        @parser = SwiftPoetryProject::TeiParser.new "#{file_path}"
        results = @parser.parse.to_xml
        expect(results).not_to match(/«.+»/)
      }.to_not raise_error
    end
  end
end
