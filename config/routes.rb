Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root "home#index"

  get '/line_callback' => 'o_auths#line_callback'
  get '/line_login' => 'o_auths#line_authorize'
end
