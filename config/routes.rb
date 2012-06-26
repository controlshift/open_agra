Agra::Application.routes.draw do
  devise_for :users, controllers: {registrations: 'registrations', sessions: 'sessions', confirmations: 'confirmations', passwords: 'passwords', omniauth_callbacks: 'users/omniauth_callbacks'} do
    match '/users/auth/facebook/setup', to: 'users/omniauth_callbacks#setup'
  end

  root to: 'home#index'
  
  mount FacebookShareWidget::Engine => "/widget"

  match 'intro' => 'home#intro', as: :intro
  match 'about_us' => 'home#about_us', as: :about_us
  match 'privacy_policy' => 'home#privacy_policy', as: :privacy_policy
  match 'tos' => 'home#tos', as: :tos
  match 'community' => 'home#community', as: :community
  match 'media' => 'home#media', as: :media
  
  get 'account' => 'users#edit'
  put 'account' => 'users#update'
  put 'account/update_password' => 'users#update_password'

  devise_scope :user do
    get 'registrations/complete' => 'registrations#completing'
    post 'registrations/complete'
  end

  resources :categories, only: [:index, :show]
  
  match 'admin' => 'admin/admin#index', as: :admin
  namespace :admin do
    resources :petitions, only: [:index] do
      collection do
        get 'search'
        get 'hot'
      end
    end
    resources :organisations
    resources :users, only: [:index, :edit, :update] do
      collection do
        get 'export'
        get 'email'
      end
    end
  end

  resource :org, controller: 'org/organisation', only: [:show, :update] do
    member do
      get 'settings'
    end
  end
  namespace :org do
    resources :petitions, only: [:index, :update] do
      collection do
        get 'search'
        get 'hot'
        get 'flagged'
        get 'moderation_queue'
      end
      resource :note, only: [:update], controller: 'petitions/note'
    end
    resources :stories
    resources :categories, except: ['show']
    resources :emails, only: [:index, :show, :update] do
      collection do
        get 'moderation'
      end
    end
    
    resources :efforts
    resources :groups do
      resources :invitations, controller: 'groups/invitations', only: [:create]
      resources :users, controller: 'groups/users'
    end
    resources :email_white_lists, only: [:new, :create]

    resources :contents do
      collection do
        get 'migrate'
        post 'import'
        get 'export'
      end
    end
    
    resources :users do
      collection do
        get 'export'
        get 'email'
      end
    end

    resource :query, only: [:new, :create]
  end

  match '/petition/new' => 'petitions#new', as: :new_petition
  get '/p/:id' => 'petitions/view#show_alias', as: :petition_alias

  resources :petitions, except: [:new, :show] do
    collection do
      get 'search'
      get 'landing', to: 'petitions#landing'
    end
    
    member do
      get 'share'
      get 'launch', to: 'petitions#launching'
      put 'launch'
      get 'thanks', to: 'petitions/view#thanks'
      post 'contact'
      get 'show', to: 'petitions/view#show'
    end

    resource :manage, controller: 'petitions/manage', only: [:edit, :update, :show] do
      get 'download_letter'
      get 'download_form'
      put 'cancel'
      put 'activate'
      get 'deliver'
      get 'offline'
      post 'contact_admin'
      post 'check_alias'
      post 'update_alias'
    end

    resources :admins, controller: 'petitions/admins', only: [:new, :create, :show, :destroy]

    resources :signatures, controller: 'petitions/signatures', only: [:index, :create, :destroy] do
      collection do
        get 'manual_input', to: 'petitions/signatures#manual_input'
        post 'manual_input', to: 'petitions/signatures#save_manual_input'
      end
      member do
        get 'confirm_destroy'
        get 'unsubscribing'
        put 'unsubscribe'
      end
    end

    resources :emails, controller: 'petitions/emails', only: [:new, :create] do
      collection do
        post 'test', to: 'petitions/emails#test'
      end
    end

    resources :flags, controller: 'petitions/petition_flags', only: [:create] do
    end
  end

  resources :efforts, only: [:show] do
    resources :petitions, controller: 'efforts/petitions', only: [:new]
    resources :near, controller: 'efforts/near', only: [:new, :index]
  end

  resources :groups, only: [:show, :index] do
    resources :invitations, controller: 'groups/invitations', only: [:show, :update]
    resources :petitions, controller: 'groups/petitions', only: [:index, :new] do
      collection do
        get 'hot'
      end
    end
    resource  :manage, controller: 'groups/manage', only: [:index, :show] do
      get 'export'
    end
  end

  get 'errors/pingdom'   #makes sure the app is up.
  get 'errors/exception' #convenient way to test if exception notification is working
  match '/admin/vanity(/:action(/:id(.:format)))', :controller=> 'admin/vanity'

  match '/404', to: 'errors#not_found'
  match '/500', to: 'errors#internal_server_error'
end
