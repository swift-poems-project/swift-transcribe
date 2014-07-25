# -*- coding: utf-8 -*-
require_relative 'spec_helper'

describe 'TeiParser' do

  it "parses single lines with single «MDUL» tokens" do

    file_path = 'spec/fixtures/tei_line_0.nb.txt'

    parser = SwiftPoetryProject::TeiParser.new file_path
    tei_xml = parser.parse
    expect(tei_xml.to_xml).not_to match(/MDUL/)
  end

  it "parses multiple stanzas with overlapping «MDUL» tokens " do

    file_path = 'spec/fixtures/tei_line_1.nb.txt'

    parser = SwiftPoetryProject::TeiParser.new file_path
    tei_xml = parser.parse
    expect(tei_xml.to_xml).not_to match(/MDUL/)
  end

=begin
  it "parses the Nota Bene document #{file_path}" do
    
    expect {

      @parser = SwiftPoetryProject::TeiParser.new "#{file_path}"
      puts @parser.parse.to_xml
    }.to_not raise_error
  end

  it "parses «MDUL» tokens" do
      
    @parser = SwiftPoetryProject::TeiParser.new "#{file_path}"
    expect(@parser.parse.to_xml).not_to match(/«MDUL»/)
  end
=end
end
