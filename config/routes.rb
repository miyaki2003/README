Rails.application.routes.draw do
  get 'reminders/index'
  root "staticpages#top"

  get '/auth/line/callback', to: 'oauths#callback'

  get "oauth/:provider" => "oauths#oauth", :as => :auth_at_provider

  post '/callback', to: 'line_bot#callback'

  get 'liff', to: 'liff#index'

  resources :events

  resources :reminders, only: %i[index destroy]
end