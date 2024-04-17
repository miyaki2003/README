Rails.application.routes.draw do
  
  get 'reminders/index'

  root "staticpages#top"

  get '/auth/line/callback', to: 'oauths#callback'

  get "oauth/:provider" => "oauths#oauth", :as => :auth_at_provider

  delete '/logout', to: 'oauths#destroy'

  post '/callback', to: 'line_bot#callback'

  get 'liff', to: 'liff#index'

  get '/terms', to: 'staticpages#terms'
  
  get '/privacy_policy', to: 'staticpages#privacy_policy'

  post '/calendar_notifications/receive', to: 'calendar_notifications#receive'

  resources :events do
    member do
      get 'details'
    end
  end

  resources :reminders, only: %i[index destroy]
end