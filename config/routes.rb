Checkout::Application.routes.draw do

  root to: 'component_models#index', filter: "checkoutable"

  # TODO: trim down these routes
  # TODO: move most of these added collection routes to params, so they can act as facets

  # extra collection routes used on 'component_models' resource
  component_models_collection_routes = Proc.new do
    ['checkoutable'].each do |r|
      get r, to: "component_models#index", filter: r
    end
  end

  devise_for :user

  resource  :app_config, :only => [:show, :edit, :update]
  resources :brands do
    collection do
      ["checkoutable", "non_checkoutable"].each do |r|
        get r, to: "brands#index", filter: r
      end
    end
    resources :models, as: "component_models", controller: "component_models" do
      collection &component_models_collection_routes
    end
  end
  resources :budgets, except: [:destroy] do
    resources :kits, only: [:index]
  end
#  resources :business_hours
#  resources :business_hour_exceptions
  resources :categories do
    collection do
      get 'select2'
      get 'suggestions'
    end
    resources :models, as: "component_models", controller: "component_models" do
      collection &component_models_collection_routes
    end
  end
  resources :components
  resources :covenants
  match 'dashboard' => 'dashboard#index'
  resources :groups
  resources :kits do
    collection do
      ['checkoutable', 'missing_components', 'non_checkoutable', 'tombstoned'].each do |r|
        get r, to: "kits#index", filter: r
      end
      get "select2"
    end
    resources :loans, only: [:index, :new]
  end
  resources :locations
  resources :models, as: "component_models", controller: "component_models" do
    collection &component_models_collection_routes
    resources :loans, only: [:new]
  end
  resources :split_model, as:"split_component_models", controller:"split_component_models", only:[:new, :create]
  resources :loans
  resources :search, only: [:index]
  resources :users, except: [:destroy] do
    collection do
      ["active", "disabled", "suspended", "admins", "attendants"].each do |r|
        get r, to: "users#index", filter: r
      end
      get "select2"
    end
    resources :groups
    resources :loans
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', as: :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
