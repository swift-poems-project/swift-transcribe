# -*- coding: utf-8 -*-

require_relative 'spec_helper'

# @todo Move this into the TeiPoem Spec
describe 'TeiPoem' do

  describe '/var/lib/spp/master/0851/545-0851' do

    before :each do
      
      @parser = SwiftPoetryProject::TeiParser.new '/var/lib/spp/master/0851/545-0851'
    end

    it "inserts an empty <l> element before each new <lg> for '_' characters in /var/lib/spp/master/0851/545-0851" do
      
      tei_doc = @parser.parse
      
      first_stanza_element = tei_doc.at_xpath('//TEI:div[@type="poem"]/TEI:lg[@n="1"]', 'TEI' => 'http://www.tei-c.org/ns/1.0')
      
      expect(first_stanza_element).to_not be_nil
      
      last_line = first_stanza_element.at_xpath('TEI:l[last()]', 'TEI' => 'http://www.tei-c.org/ns/1.0')
      
      expect(last_line).to_not be_nil
      expect(last_line['n']).to be_nil
    end
    
    it "creates new <lg> elements for '|' characters in /var/lib/spp/master/0851/545-0851" do
      
      tei_doc = @parser.parse
      
      first_stanza_element = tei_doc.at_xpath('//TEI:div[@type="poem"]/TEI:lg[@n="1"]', 'TEI' => 'http://www.tei-c.org/ns/1.0')
      
      expect(first_stanza_element).to_not be_nil
      
      last_line = first_stanza_element.at_xpath('TEI:l[@n="4"]', 'TEI' => 'http://www.tei-c.org/ns/1.0')
      
      expect(last_line).to_not be_nil
      
      second_stanza_element = tei_doc.at_xpath('//TEI:div[@type="poem"]/TEI:lg[@n="2"]', 'TEI' => 'http://www.tei-c.org/ns/1.0')
      
      expect(second_stanza_element).to_not be_nil
      puts second_stanza_element.to_xml
      
      last_line = second_stanza_element.at_xpath('TEI:l[@n="5"]', 'TEI' => 'http://www.tei-c.org/ns/1.0')
      expect(last_line).to_not be_nil
      
      last_line = second_stanza_element.at_xpath('TEI:l[@n="7"]', 'TEI' => 'http://www.tei-c.org/ns/1.0')
      expect(last_line).to be_nil
    end
  end
  
  describe '/var/lib/spp/master/0871/953A0871' do
    
    before :each do
      
      @parser = SwiftPoetryProject::TeiParser.new "/var/lib/spp/master/0871/953A0871"
    end
    
    it "does not create new <lg> elements for multiple '|' characters in /var/lib/spp/master/0871/953A0871" do
      
      tei_doc = @parser.parse
      
      first_stanza_element = tei_doc.at_xpath('//TEI:div[@type="poem"]/TEI:lg[@n="1"]', 'TEI' => 'http://www.tei-c.org/ns/1.0')
      
      expect(first_stanza_element).to_not be_nil

      
    end
  end
end
