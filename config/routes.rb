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
end
