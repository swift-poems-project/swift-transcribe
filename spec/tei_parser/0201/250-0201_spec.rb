# -*- coding: utf-8 -*-
require_relative '../../spec_helper'

describe 'TeiParser' do

  before :each do

    @nb_store_path = '/usr/share/spp/ruby-tools/spp/master'
  end

  @nb_store_path = '/usr/share/spp/ruby-tools/spp/master'
  file_path = "#{@nb_store_path}/0201/250-0201"

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
end
