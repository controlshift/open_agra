require 'sidekiq/web'

Agra::Application.routes.draw do

  pulse # for monitoring

  devise_for :users, controllers: {registrations: 'registrations', sessions: 'sessions', confirmations: 'confirmations', passwords: 'passwords', omniauth_callbacks: 'users/omniauth_callbacks'} do
    match '/users/auth/facebook/setup', to: 'users/omniauth_callbacks#setup'
  end

  constraint = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.admin? }
  constraints constraint do
    mount Sidekiq::Web => '/sidekiq'
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
        get 'jobs'
      end
    end
  end

  resource :org, controller: 'org/organisation', only: [:show, :update] do
    member do
      get 'settings'
    end
    resource :placeholder, controller: 'org/organisation/placeholder', only: [:show, :update]
  end
  namespace :org do
    resources :csv_reports, only: [:show]
    resources :comments, only: [:index] do
       member do
        put 'approve'
        put 'remove'
       end
    end
    resources :petitions, only: [:index, :update, :show] do
      collection do
        get 'search'
        get 'hot'
        get 'flagged'
        get 'moderation_queue'
      end
      resources :signatures, only: [:index, :destroy], controller: 'petitions/signatures' do
        collection do
          get 'email'
        end

        member do
          put 'unsubscribe'
        end
      end
      resource :settings, only: [:show, :update], controller: 'petitions/settings'
      resource :note, only: [:update], controller: 'petitions/note'
      resource :user, only: [:edit, :update], controller: 'petitions/user'
      resources :flags, only: [:index], controller: 'petitions/flags'
      resources :facebook_share_variants, controller: 'petitions/facebook_share_variants'
      resources :comments, only: [:index], controller: 'petitions/comments' do
        member do
          put 'approve'
          put 'remove'
        end
      end
    end
    resources :categories, except: ['show']
    resources :emails, only: [:index, :show, :update] do
      collection do
        get 'moderation'
      end
    end

    resources :landing_pages

    resources :efforts do
      resources :leaders, controller: 'efforts/leaders', only: [:show, :destroy]
      resources :petitions, controller: 'efforts/petitions', only: [] do
        member do
          get 'check'
          post 'move'
          put 'note'
        end
      end

      resources :imports, controller: 'efforts/imports', only: [:new, :create]
      resources :targets, controller: 'efforts/targets', only: [:new, :create, :index, :edit, :update] do
        collection do
          get 'find'
          post 'add'
          put  'add_collection'
        end



        member {delete 'remove'}
      end
    end

    resources :groups, :path => 'partnerships'do
      resources :invitations, controller: 'groups/invitations', only: [:create]
      resources :users, controller: 'groups/users'
      resources :petitions, controller: 'groups/petitions', only: [] do
        member do
          get 'check'
          post 'move'
        end
      end
    end
    resources :email_white_lists, only: [:new, :create]

    namespace :contents do
      resources :stories
      resources :templates
    end

    resources :contents do
      collection do
        get 'migrate'
        post 'import'
        get 'export'
      end
    end

    resources :members, only: [:show, :index] do
      collection do
        get 'email'
      end
    end

    resources :users do
      collection do
        get 'export'
        get 'email'
        get 'bad_postcodes'
      end
    end

    resource :query, only: [:new, :create]
    resources :exports, only: [:index] do
      collection do
        get 'petitions'
        get 'signatures'
        get 'members'
      end
    end
  end

  match '/petition/new' => 'petitions#new', as: :new_petition
  get '/p/:id' => 'petitions/view#show_alias', as: :petition_alias

  namespace :petitions do
    resources :near, only: [:new, :index] do
      member do
        get 'embed'
        get 'iframe'
      end
    end
    resources :locations, only: [:index]
    resources :countries, only: [:show] do
      member do
        get 'embed'
        get 'iframe'
      end
    end
  end

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
      get 'show', to: 'petitions/view#show'
    end

    resources :facebook_share_variants, controller: 'petitions/facebook_share_variants', only: [:show, :update]
    resources :contacts, controller: 'petitions/contacts', only: [:new, :create]

    resource :categories, controller: 'petitions/categories', only: [:show, :update]

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
      get 'training'
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

    resources :comments, controller: 'petitions/comments', only: [:index, :show] do
      resources :flags, controller: 'petitions/comments/flags', only: [:new, :create]
      member do
        post 'create', :as => :create
        put 'like'
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

  resources :shares, only:[:show] do
    collection { get 'lookup' }
  end

  resources :efforts, only: [:show] do
    member { get 'locations' }
    resources :petitions, controller: 'efforts/petitions', only: [:new, :edit, :update] do
      member do
        get 'leading'
        put 'lead'
        get 'training'
        put 'train'
      end
    end
    resources :near, controller: 'efforts/near', only: [:new, :index]
  end

  resources :groups, only: [:index, :show], :path => 'partnerships' do
    resources :unsubscribes, controller: 'groups/unsubscribes', only: [:show, :update]
    resources :invitations, controller: 'groups/invitations', only: [:show, :update]
    resources :petitions, controller: 'groups/petitions', only: [:index, :new] do
      collection do
        get 'hot'
      end
    end
    resource  :manage, controller: 'groups/manage', only: [:index, :show] do
      get 'export'
    end
    resources :emails, controller: 'groups/emails', only: [:new, :create] do
      collection do
        post 'test', to: 'groups/emails#test'
      end
    end
  end

  match 'cached_url/*uri' => 'cached_url#retrieve', as: :cached_embedly

  get 'errors/pingdom'   #makes sure the app is up.
  get 'errors/exception' #convenient way to test if exception notification is working
  get 'errors/streaming' # test for streaming responses.

  match '/404', to: 'errors#not_found'
  match '/500', to: 'errors#internal_server_error'
end
