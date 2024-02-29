Rails.application.routes.draw do
  get 'staticpages/top'

  root "staticpages#top"
  
  resources :calendars, only: %i[index]

  devise_for :line_users, controllers: {
  omniauth_callbacks: "omniauth_callbacks"
  }
end
