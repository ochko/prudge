Prudge::Application.routes.draw do
  match ':controller/feed.rss' => '#index', :format => 'rss'
  match ':controller/list' => '#index'
  resources :users do
    collection do
      get :account
    end
    member do
      get :solutions
      get :problems
    end
    resources :posts
  end

  resources :password_resets
  resource :user_session
  resources :contests do
    member do
      get :contestants
      post :watch
      post :unwatch
    end
    resources :problems, :only => :show do
      resources :solutions
    end
    resources :users, :only => :show do
      resources :solutions, :only => :index
    end
  end
  resources :participants
  resources :problems do
    resources :solutions
    collection do
      get :proposed
    end
    member do
      get :check
    end
  end
  resources :posts, :except => :index do
    collection do
      get :blog
      get :help
    end
  end
  resources :lessons
  resources :topics
  resources :solutions do
    collection do
      get :latest
    end
    member do
      get :submited
      get :view
      get :download
    end
  end

  resources :pages
  resources :problem_tests
  resources :results
  resources :comments do
    collection do
      get :moderate
    end
  end

  match 'signup' => 'users#new', :as => :signup
  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout
  match 'forgot_password' => 'password_resets#new', :as => :forgot_password

  match 'about' => 'home#about', :as => :about
  match 'dashboard' => 'home#dashboard', :as => :dashboard
  match '/search/:q' => 'search#index'

  root :to => 'contests#last'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
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
