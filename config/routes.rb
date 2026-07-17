Rails.application.routes.draw do
  get "games", to: "pages#games"
  get "games/rubordle", to: "pages#rubordle"
  get "games/sudoku", to: "pages#sudoku"
  get "tools", to: "pages#tools"
  get "tools/image-resize", to: "pages#image_resize", as: :image_resize_tool
  get "chat", to: "chats#show"
  post "chat/messages", to: "chats#messages", as: :chat_messages
  resources :photos, only: [:index, :show], param: :slug
  resources :posts, only: [:index, :show], param: :slug

  namespace :admin do
    resources :photos, param: :slug
    resources :uploads, only: [:create]
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
