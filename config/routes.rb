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
end
