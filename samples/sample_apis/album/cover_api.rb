module AlbumServices
  class Cover < Grape::API
    format :json
    desc 'Ping'
    namespace :album do
      get ':id/cover' do
        { cover: 'image' }
      end
    end
  end
end
