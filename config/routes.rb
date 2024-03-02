Rails.application.routes.draw do
  get 'staticpages/top'

  root "staticpages#top"
  
  resources :calendars, only: %i[index]

  get 'oauth/callback', to: 'oauths#callback'

  get "oauth/:provider" => "oauths#oauth", :as => :auth_at_provider

  resources :events, except: %i[show]
end