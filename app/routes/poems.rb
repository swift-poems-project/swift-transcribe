
module Routes
  class Poems < Base
    
    # Handles the request for browsing a poem
    get '/poems/:poem_id', :provides => 'json' do
      poem_id = params[:poem_id]
      
      response = []
      nota_bene_store.transcripts(poem_id: poem_id).each do |result|
    
        transcript_id = result[:id]
        response << {id: transcript_id }
      end

      return JSON.generate(response)
    end

    # Requests for all poems
    get %r{/poems/?}, :provides => 'json' do
      response = nota_bene_store.poem_codes
      return JSON.generate(response)
    end
  end
end
