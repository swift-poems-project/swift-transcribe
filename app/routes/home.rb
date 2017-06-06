
module Routes
  class Home < Base
    get '/' do
      haml :index
    end
  end
end
