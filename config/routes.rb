Rails.application.routes.draw do
  get 'staticpages/top'

  root "staticpages#top"
  
  resources :calendars, only: %i[index]

  get '/auth/:provider/callback', to: 'sessions#create'
end