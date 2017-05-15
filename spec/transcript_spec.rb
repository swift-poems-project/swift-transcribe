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

    it "parses the titles for #{@file_path} without error" do
      
      transcript = SwiftPoemsProject::Transcript.new @nota_bene
      title_elems = transcript.tei.document.xpath('tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title', {'tei' => 'http://www.tei-c.org/ns/1.0'})
      expect(title_elems.length).to eq(1)

      title_elem = title_elems.shift

      lb_elems = title_elem.xpath('tei:lb', {'tei' => 'http://www.tei-c.org/ns/1.0'})
      expect(lb_elems.length).to eq(1)
      
      expect(title_elem.content).to eq("On the five Lady's at Sots-hole and theDoctor at their head")
    end
  end
end
