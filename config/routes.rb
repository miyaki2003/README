Rails.application.routes.draw do
  get 'reminders/index'
  root "staticpages#top"

  get '/auth/line/callback', to: 'oauths#callback'

  get "oauth/:provider" => "oauths#oauth", :as => :auth_at_provider

  delete '/logout', to: 'oauths#destroy', as: :logout

  post '/callback', to: 'line_bot#callback'

  get '/staticpages/privacy_policy', to: 'staticpages#privacy_policy'

  get '/staticpages/terms', to: 'staticpages#terms'

  get '/line_friends', to: redirect('https://line.me/R/ti/p/%40083jbanw')

  resources :events do
    member do
      patch :deactivate
    end
  end

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  resources :reminder_lists, only: [:index] do
    member do
      patch :deactivate
    end
  end
end
