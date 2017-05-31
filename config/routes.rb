Rails.application.routes.draw do
  resources :operations, only: [:index] do
    collection do
      get :import
      post :import
    end
  end
end
