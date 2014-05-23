LineItemImporter::Application.routes.draw do

  resources :attachments, except: [:edit] do
    resources :mappings, only: [:new, :create]
    resources :imports, only: [:new, :create]
  end
  resources :mappings, only: [:index, :show]
  resources :imports, only: [:index, :show]

  match 'login' => 'sessions#create', via: :post, as: :login
  match 'login_success' => 'sessions#new', via: :get, as: :login_success

  match '/documents' => 'documents#autocomplete', via: :get, as: :autocomplete

  root to: 'frontend#index'
end
