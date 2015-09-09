Rails.application.routes.draw do
  root to: 'visitors#index'

  resources :tasks do
    member do
      put :mark_as_done
    end

    resources :child_tasks, only: [:create, :new]
  end
end
