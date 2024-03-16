Rails.application.routes.draw do
  get 'fullcalendar/index'
  get 'liff/index'
  get 'staticpages/top'

  root "staticpages#top"

  get '/auth/line/callback', to: 'oauths#callback'  

  get "oauth/:provider" => "oauths#oauth", :as => :auth_at_provider

  resources :events

  post '/callback', to: 'line_bot#callback'

  get 'liff', to: 'liff#index'

  get 'fullcalendar', to: 'fullcalendar#index'
end