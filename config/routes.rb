Rails.application.routes.draw do
  get '/', to: 'welcome#index'

  get "/register", to: "golfers#new"
  post "/golfers", to: "golfers#create"
  get "/dashboard", to: "golfers#show"

  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  get "/logout", to: "sessions#destroy"

  get "/register_trip", to: "golfer_trips#new"
  post "/register_trip", to: "golfer_trips#create"

  put "/update_golfer_payment", to: "golfer_trips#update"

  post "/payments", to: "payments#create"

  get "/finances", to: "finances#index"

  get   "/forgot_password",             to: "password_resets#new"
  post  "/password_resets",             to: "password_resets#create"
  get   "/password_resets/:token/edit", to: "password_resets#edit",   as: :edit_password_reset
  patch "/password_resets/:token",      to: "password_resets#update", as: :password_reset
end
