Prudge::Application.routes.draw do
  match ':controller/feed.rss' => '#index', :format => 'rss'
  match ':controller/list' => '#index'
  resources :users do
    member do
      :solutions
      :lessons
      :problems
    end
  end

  resources :password_resets
  resource :user_session
  resources :contests
  resources :participants
  resources :problems do
    member do
      :check
    end
  end

  resources :lessons
  resources :topics
  resources :solutions do
    member do
      :best
      :submited
      :solved
      :view
      :download
    end
  end

  resources :languages
  resources :pages
  resources :problem_tests
  resources :results
  resources :comments

  match '/' => 'contests#last'
  match 'signup' => 'users#new', :as => :signup
  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout
  match 'forgot_password' => 'password_resets#new', :as => :forgot_password
  match 'account' => 'users#account', :as => :account
  match 'home' => 'home#index', :as => :home
  match 'help' => 'home#help', :as => :help
  match 'about' => 'home#about', :as => :about
  match 'rules' => 'home#rules', :as => :rules
  match 'proposals' => 'problems#proposals', :as => :proposals
  match '/moderate' => 'comments#moderate'
  match '/topic/:type' => 'topics#index'
  match '/search/:q' => 'search#index'
  match '/watchers/:id/:action' => 'watchers#index'
  match '/:controller(/:action(/:id))'
end
