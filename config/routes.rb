ActionController::Routing::Routes.draw do |map|
  map.resources :users
  map.resources :password_resets
  map.resource :user_session

  map.resources :contests
  map.resources :problems
  map.resources :lessons
  map.resources :topics
  map.resources :solutions, :member =>[:best, :submited, :solved, :view]
  map.resources :languages
  map.resources :pages
  map.resources :problem_tests
  map.resources :results
  map.resources :comments

  map.root :controller => 'contests', :action => 'last'
  map.signup 'signup', :controller => 'users', :action => 'new'
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'
  map.forgot_password 'forgot_password', :controller => 'password_resets', :action => 'new'
  map.account 'account', :controller => 'users', :action => 'account'
  map.home 'home', :controller => 'home'
  map.help 'help', :controller => 'home', :action => 'help'
  map.about 'about', :controller => 'home', :action => 'about'
  map.rules 'rules', :controller => 'home', :action => 'rules'
  map.last 'last', :controller => 'solutions', :action => 'last'
  map.connect '/search/:q', :controller => 'search'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
