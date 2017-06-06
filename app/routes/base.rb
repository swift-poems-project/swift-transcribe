
module Routes
  class Base < Sinatra::Application
    SCOPE = Google::Apis::DriveV3::AUTH_DRIVE_READONLY
    NAME = 'Swift Poems Project Transcription Service'
    CLIENT_SECRETS_PATH = File.join(File.dirname(__FILE__), '..', '..', 'config', 'client_secret.json')
    NB_CACHE_PATH = File.join(File.dirname(__FILE__), '..', '..', 'tmp', 'nb')
    POEMS_CONFIG_PATH = File.join(File.dirname(__FILE__), '..', '..', 'config', 'poems.yml')
    TEI_CACHE_PATH = File.join(File.dirname(__FILE__), '..', '..', 'tmp', 'tei')
    
    not_found do
      halt response.body
    end

    error do
      halt "Error: #{env['sinatra.error'].message}"
    end

    def encoder
      @encoder || @encoder = SwiftPoemsProject::Encoder::TeiEncoder.new(TEI_CACHE_PATH)
    end
    
    def nota_bene_store
      @nota_bene_store || @nota_bene_store = SwiftPoemsProject::GDrive::NotaBeneStore.new(CLIENT_SECRETS_PATH, SCOPE, NAME, NB_CACHE_PATH, POEMS_CONFIG_PATH)
    end
  end
end
