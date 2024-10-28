Rails.application.routes.draw do
  resources :carts do
    member do
      delete :empty
    end
  end
  
  resources :products
  resources :line_items
  devise_for :users, controllers: {
    registrations: 'registrations'
  }
  root 'products#index'
end
