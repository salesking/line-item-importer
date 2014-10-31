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
  match 'attachments/:id/mappings/check_document' => 'mappings#check_document', via: :get, as: :check_document

  root to: 'frontend#index'
end
