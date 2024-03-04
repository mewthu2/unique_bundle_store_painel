require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :user, skip: [:registrations]
  root to: 'home#index'

  resources :dashboard do
    collection do
      get :view_live_orders
      get :search_specific_order
      get :search_order_items
      post :change_order_markup_status
      post :generate_spreadsheet
    end
  end

  resources :products do
    collection do
      get :find_by_seller_sku
    end
  end
  resources :product_preparations do
    get :generate_tag, defaults: { format: :pdf }, on: :collection
    get :generate_fnsku_tag, defaults: { format: :pdf }, on: :collection
  end

  resources :order_marks
end
