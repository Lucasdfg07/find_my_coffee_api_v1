Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      resources :ratings, :defaults => { :format => 'json' }
      resources :stores, :defaults => { :format => 'json' }
      resources :google_stores, :defaults => { :format => 'json' }
    end
  end
  
end
