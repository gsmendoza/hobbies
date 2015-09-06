Rails.application.routes.draw do
  root to: 'visitors#index'

  resources :tasks, only: [] do
    member do
      put :mark_as_done
    end
  end
end
