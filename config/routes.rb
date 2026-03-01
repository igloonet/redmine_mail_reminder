resources :mail_reminders, only: [:index, :create, :update, :destroy] do
  collection do
    post :update_interval_values
  end
end
