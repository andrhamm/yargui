Rails.application.routes.draw do
  get :home, controller: :application
  # match "*path", to: "application#home", via: :all
end
