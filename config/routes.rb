Rails.application.routes.draw do
  devise_for :line_users
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  get 'staticpages/top'

  get "up" => "rails/health#show", as: :rails_health_check

  root "staticpages#top"
  resources :calendars, only: %i[index]

end