# -*- coding: utf-8 -*-

require_relative 'spec_helper'

describe 'NotaBene' do

  before :all do

     @nb_store_path = '/var/lib/spp/master'
  end

  describe 'Document' do

    before :all do

      @file_path = File.join(@nb_store_path, '001B', '425-001B')
    end

    describe "#initialize" do

      it "parses the transcript #{@file_path} without error" do

        expect {
          SwiftPoemsProject::NotaBene::Document.new @file_path
        }.to_not raise_error
      end
    end

    describe "#tokenize" do

      before :each do

        @document = SwiftPoemsProject::NotaBene::Document.new @file_path
      end

      it "tokenizes #{@file_path} without error" do

        expect {
          @document.tokenize
        }.to_not raise_error
      end
    end
  end
end
