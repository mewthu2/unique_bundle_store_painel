require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :user, skip: [:registrations]
  root to: 'home#index'

  resources :dashboard do
    collection do
      post :generate_spreadsheet
    end
  end

  resources :products
  resources :product_preparations do
    get :generate_tag, defaults: { format: :pdf }, on: :collection
  end
end
