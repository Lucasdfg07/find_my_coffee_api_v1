Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      resources :ratings
      resources :stores do
        collection do
          get :search_stores_in_geolocation
        end
      end
    end
  end
  
end
