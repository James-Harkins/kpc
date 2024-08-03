Rails.application.routes.draw do
  get '/', to: 'welcome#index'

  get "/register", to: "golfers#new"
  post "/golfers", to: "golfers#create"
  get "/dashboard", to: "golfers#show"

  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  get "/logout", to: "sessions#destroy"

  get "/register_trip", to: "golfer_trips#new"
  post "/golfer_trips", to: "golfer_trips#create"
end
