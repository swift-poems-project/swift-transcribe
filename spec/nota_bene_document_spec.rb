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

    describe "#tokenize_titles" do
      before :each do

        @document = SwiftPoemsProject::NotaBene::Document.new @file_path
      end

      it "tokenizes Nota Bene markup within the title" do

        tokens = @document.tokenize_titles("026-07G1   POSTHUMOUS PIECES in VERSE «FN1·This is the title given to the poems that follow, by Mr. Hawkesworth: though it is certain, that several of them were published in the author's life time.» | O«MDSD»DE«MDNM» to the Hon. Sir W«MDSD»ILLIAM «MDNM»T«MDSD»EMPLE«MDNM». «FN1·When the author's posthumous pieces were reprinted in Ireland, this and the subsequent odes were omitted. «MDUL»Hawkes«MDNM».────── These two odes, and a third, an ode to K. William, when his Majesty was in Ireland, are the only Specimens of Dr Swift's that I know of in the Pindaric measure. It is reported, that, in the early part of his life, he writ several poems in that irregular kind of metre; whereby it is certain, that he acquired no sort of reputation. I have been told, that his cousin the famous John Dryden expressed a good deal of contempt for a pretty large collection of these poems, which had been shown to him in manuscript by his bookseller: for which treatment I verily believe it was, that, in return to his compliment, the Doctor hath on all occasions been so unmercifully severe upon that famous writer. But this kind of usage among the sticklers for reputation, is sanctified by immemorial prescription. To the best of my remembrance Dryden himself hath declared._|«MDUL»Poets should ne'er be drones, mean harml·ss things;_|But guard, like bees, their labours by their stings.«MDNM»_|||||Swift.»")

        expect(tokens).to eq ["026-07G1   POSTHUMOUS PIECES in VERSE ", "«FN1·", "This is the title given to the poems that follow, by Mr. Hawkesworth: though it is certain, that several of them were published in the author's life time", ".»", " |", " O", "«MDSD»", "DE", "«MDNM»", " to the Hon. Sir W", "«MDSD»", "ILLIAM ", "«MDNM»", "T", "«MDSD»", "EMPLE", "«MDNM»", ". ", "«FN1·", "When the author's posthumous pieces were reprinted in Ireland, this and the subsequent odes were omitted. ", "«MDUL»", "Hawkes", "«MDNM»", ".────── These two odes, and a third, an ode to K. William, when his Majesty was in Ireland, are the only Specimens of Dr Swift's that I know of in the Pindaric measure. It is reported, that, in the early part of his life, he writ several poems in that irregular kind of metre; whereby it is certain, that he acquired no sort of reputation. I have been told, that his cousin the famous John Dryden expressed a good deal of contempt for a pretty large collection of these poems, which had been shown to him in manuscript by his bookseller: for which treatment I verily believe it was, that, in return to his compliment, the Doctor hath on all occasions been so unmercifully severe upon that famous writer. But this kind of usage among the sticklers for reputation, is sanctified by immemorial prescription. To the best of my remembrance Dryden himself hath declared.", "_|", "«MDUL»", "Poets should ne'er be drones, mean harml·ss things;", "_|", "But guard, like bees, their labours by their stings.", "«MDNM»", "_|", "||||Swift", ".»"]
      end
    end
  end
end
