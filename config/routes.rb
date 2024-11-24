Rails.application.routes.draw do
  resources :carts do
    member do
      delete :empty
    end
  end
  
  resources :products
  resources :line_items do
    member do
      patch :update_quantity
    end
  end
  devise_for :users, controllers: {
    registrations: 'registrations'
  }
  root 'products#index'
  post '/stkpush', to: 'mpesa#stkpush'
  post '/mpesa/callback', to: 'mpesa#callback'
  post '/stkquery', to: 'mpesa#stkquery'
  resources :checkouts, only: [:new, :create] do
    get 'confirmation', on: :member
  end
  
end