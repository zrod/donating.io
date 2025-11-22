Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root "places#index"

  resource :user, only: %i[
    new
    create
    edit
    update
  ]

  resources :places, only: %i[
    index
    new
    create
    show
    edit
    update
    destroy
  ], param: :slug do
    collection do
      get :my_contributions
      delete :bulk_delete
    end
  end

  scope "pages" do
    get "about", to: "pages#about"
    get "privacy", to: "pages#privacy"
    get "terms", to: "pages#terms"
  end

  post "geo_terms/search", to: "geo_terms_search#create"
end
