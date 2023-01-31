Rails.application.routes.draw do
  post 'deposit' => 'buyer#deposit'
  post 'buy/:product_id' => 'buyer#purchase'
  post 'reset' => 'buyer#reset'

  post 'login' => 'auth#create'
  post 'logout' => 'auth#destroy'
  post 'logout/all' => 'auth#destroy_all_other'

  resources :products
  resources :users, only: [:create, :update, :show, :destroy]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
