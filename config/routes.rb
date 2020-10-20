Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users
    end

    post 'auth/login', to: 'authentication#authenticate'
  end
end
