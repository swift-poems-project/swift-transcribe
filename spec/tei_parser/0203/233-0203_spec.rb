require_relative '../../spec_helper'

describe 'TeiParser' do

  it "parses the Nota Bene document /usr/share/spp/ruby-tools/spp/master/0203/233-0203" do

    expect {

      @parser = SwiftPoetryProject::TeiParser.new "/usr/share/spp/ruby-tools/spp/master/0203/233-0203"
      @parser.parse.to_xml
    }.to_not raise_error
  end
end
