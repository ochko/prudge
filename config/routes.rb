Prudge::Application.routes.draw do
  match ':controller/feed.rss' => '#index', :format => 'rss'
  match ':controller/list' => '#index'
  resources :users do
    member do
      get :solutions
      get :lessons
      get :problems
    end
  end

  resources :password_resets
  resource :user_session
  resources :contests
  resources :participants
  resources :problems do
    member do
      get :check
    end
  end

  resources :lessons
  resources :topics
  resources :solutions do
    member do
      get :best
      get :submited
      get :solved
      get :view
      get :download
    end
  end

  resources :languages
  resources :pages
  resources :problem_tests
  resources :results
  resources :comments

  root :to => 'contests#last'
  match 'signup' => 'users#new', :as => :signup
  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout
  match 'forgot_password' => 'password_resets#new', :as => :forgot_password
  match 'account' => 'users#account', :as => :account
  match 'home' => 'home#index', :as => :home
  match 'about' => 'home#about', :as => :about
  match 'guide' => 'home#guide', :as => :guide
  match 'proposals' => 'problems#proposals', :as => :proposals
  match '/moderate' => 'comments#moderate'
  match '/topic/:type' => 'topics#index'
  match '/search/:q' => 'search#index'
  match '/watchers/:id/:action' => 'watchers#index'

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
