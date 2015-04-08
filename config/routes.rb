Rails.application.routes.draw do
  get :home, controller: :application
  root to: 'application#home'
end
