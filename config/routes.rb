Rails.application.routes.draw do
  get "games", to: "pages#games"
  get "games/rubordle", to: "pages#rubordle"
  get "games/sudoku", to: "pages#sudoku"
  resources :photos, only: [:index, :show], param: :slug
  resources :posts, only: [:index, :show], param: :slug

  namespace :admin do
    resources :photos, param: :slug
    resources :posts, param: :slug do
      member do
        get :preview
        patch :publish
        patch :unpublish
      end
    end
  end

  root "pages#home"
end
