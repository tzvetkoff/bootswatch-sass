Rails.application.routes.draw do
  root :to => 'home#index'
  get ':theme' => 'home#index'
end
