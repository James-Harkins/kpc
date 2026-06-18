Rails.application.routes.draw do
  get '/', to: 'welcome#index'

  get "/register", to: "golfers#new"
  post "/golfers", to: "golfers#create"
  get "/dashboard", to: "golfers#show"

  get   "/profile/edit", to: "golfers#edit"
  patch "/profile",      to: "golfers#update"

  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  get "/register_trip", to: "golfer_trips#new"
  post "/register_trip", to: "golfer_trips#create"

  put "/update_golfer_payment", to: "golfer_trips#update"

  post "/payments", to: "payments#create"
  post "/returns",  to: "returns#create"

  get  "/finances",                  to: "finances#index"
  get  "/attendance",                to: "attendance#index",  as: :attendance
  get  "/previous_trips",            to: "previous_trips#index", as: :previous_trips
  post "/trip_financial_summaries",  to: "trip_financial_summaries#create", as: :trip_financial_summaries

  get "/roster", to: "rosters#index"
  get '/scoreboard', to: 'scoreboards#index', as: :scoreboard

  get  "/announcements/new", to: "announcements#new"
  post "/announcements",     to: "announcements#create"

  get   "/forgot_password",             to: "password_resets#new"
  post  "/password_resets",             to: "password_resets#create"
  get   "/password_resets/:token/edit", to: "password_resets#edit",   as: :edit_password_reset
  patch "/password_resets/:token",      to: "password_resets#update", as: :password_reset

  # Golfer management (site admin)
  get    '/admin/golfer/new',              to: 'golfers#admin_new',    as: :admin_new_golfer
  post   '/admin/golfer',                  to: 'golfers#admin_create', as: :admin_golfer
  patch  '/admin/golfers/:id/make_admin',  to: 'golfers#make_admin',   as: :make_admin_golfer
  patch  '/admin/golfers/:id/make_default', to: 'golfers#make_default', as: :make_default_golfer
  delete '/admin/golfers/:id',             to: 'golfers#destroy',      as: :destroy_admin_golfer

  # Trip management (admin)
  get   '/trips/new',          to: 'trips#new',      as: :new_trip
  post  '/trips',              to: 'trips#create'
  get   '/trips/:id/edit',     to: 'trips#edit',     as: :edit_trip
  patch '/trips/:id',          to: 'trips#update',   as: :trip
  patch '/trips/:id/complete', to: 'trips#complete', as: :complete_trip

  # Course management (admin)
  get   '/courses',          to: 'courses#index',  as: :courses
  get   '/courses/new',      to: 'courses#new',    as: :new_course
  post  '/courses',          to: 'courses#create'
  get   '/courses/:id/edit', to: 'courses#edit',   as: :edit_course
  patch '/courses/:id',      to: 'courses#update', as: :course

  # Expense management (admin)
  get    '/expenses',          to: 'expenses#index',   as: :expenses
  get    '/expenses/new',      to: 'expenses#new',     as: :new_expense
  post   '/expenses',          to: 'expenses#create'
  get    '/expenses/:id/edit', to: 'expenses#edit',    as: :edit_expense
  patch  '/expenses/:id',      to: 'expenses#update',  as: :expense
  delete '/expenses/:id',      to: 'expenses#destroy'

  # Golfer trip admin editing
  get   '/golfer_trips/:id/edit', to: 'golfer_trips#edit',         as: :edit_golfer_trip
  patch '/golfer_trips/:id',      to: 'golfer_trips#admin_update', as: :golfer_trip

  # Tournament
  get   '/tournament',          to: 'tournaments#index',       as: :tournament
  post  '/tournament/generate', to: 'tournaments#generate',    as: :generate_tournament
  post  '/tournament/redraw',   to: 'tournaments#redraw',      as: :redraw_tournament
  patch '/tournament/captains', to: 'tournaments#update_captains', as: :tournament_captains

  # Round score entry
  get   '/rounds/:id/scores', to: 'golfer_rounds#edit',   as: :edit_round_scores
  patch '/rounds/:id/scores', to: 'golfer_rounds#update', as: :round_scores

  # Tournament assignment overrides
  patch '/tournament_assignments/:id', to: 'tournament_assignments#update', as: :tournament_assignment

  # Tournament matchup results
  patch '/tournament_matchup_results/:round_id', to: 'tournament_matchup_results#update', as: :tournament_matchup_results
end
