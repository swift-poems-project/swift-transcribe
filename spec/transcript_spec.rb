# -*- coding: utf-8 -*-

require_relative 'spec_helper'

describe 'Transcript' do
  
  before :all do

    @nb_store_path = '/var/lib/spp/master'    
    @file_path = File.join(@nb_store_path, '001B', '425-001B')
  end

  before :each do

    @nota_bene = SwiftPoemsProject::NotaBene::Document.new @file_path
  end
  
  describe "#initialize" do
    
    it "parses the transcript #{@file_path} without error" do
      
      expect {
        SwiftPoemsProject::Transcript.new @nota_bene
      }.to_not raise_error
    end
  end
end
