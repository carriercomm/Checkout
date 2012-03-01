Checkout::Engine.routes.draw do
  resources :kits

  resources :locations

  resources :asset_tags

  resources :categories

  resources :makers

  resources :parts

  resources :models

end
