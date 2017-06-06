module Routes
  class Transcripts < Routes::Base
    
    # Requesting that an individual transcript file be encoded (including the source ID)
    get '/transcripts/:source_id/:transcript_id/encode', :provides => 'application/tei+xml' do
      source_id = params[:source_id]
      transcript_id = params[:transcript_id]

      results = nota_bene_store.transcript(transcript_id)
      transcript = results[:content].encode('utf-8','cp437')
      nota_bene_mtime = results[:mtime]

      return encoder.encode(transcript_id, transcript, nota_bene_mtime)
    end

    # Requesting that an individual transcript file be encoded
    get '/transcripts/:transcript_id/encode', :provides => 'application/tei+xml' do
      transcript_id = params[:transcript_id]

      results = nota_bene_store.transcript(transcript_id)
      transcript = results[:content].encode('utf-8','cp437')
      nota_bene_mtime = results[:mtime]

      return encoder.encode(transcript_id, transcript, nota_bene_mtime)
    end
    
    # Requesting that a transcript be encoded using the data in the request payload
    post '/transcripts/encode', :provides => 'application/tei+xml' do
      transcript_id = params['id']
      transcript = params['transcript']

      return encoder.encode(transcript_id, transcript, Date.today)
    end
  end
end
