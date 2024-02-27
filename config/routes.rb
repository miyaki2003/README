Rails.application.routes.draw do

  get 'staticpages/top'

  get "up" => "rails/health#show", as: :rails_health_check

  root "staticpages#top"
  resources :calendars, only: %i[index]
  
  devise_for :line_users, controllers: {
    omniauth_callbacks: "omniauth_callbacks"
  }

end