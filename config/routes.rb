Rails.application.routes.draw do
  resources :attachments, except: [:edit] do
    resources :mappings, only: [:new, :create, :destroy]
    resources :imports, only: [:new, :create, :destroy]
  end
  resources :mappings, only: [:index, :show, :destroy]
  resources :imports, only: [:index, :show, :destroy]

  match 'login' => 'sessions#create', via: :post, as: :login
  match 'login_success' => 'sessions#new', via: :get, as: :login_success

  match '/documents' => 'documents#autocomplete', via: :get, as: :autocomplete

  #match 'reuse' => 'mappings#reuse', via: :post, as: :reuse

  root to: 'frontend#index'
end
