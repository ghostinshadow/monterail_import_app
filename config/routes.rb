Rails.application.routes.draw do
  resources :operations, only: [:index] do
    collection do
      post :import
    end
  end
  root 'operations#index'
end
