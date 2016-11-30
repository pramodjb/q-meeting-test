 Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # -----------
  # Public APIs
  # -----------

  # Authenticate API
  post '/api/v1/authenticate' => 'api/v1/authentications#authenticate'

  # -----------
  # User APIs
  # -----------
  
  get '/api/v1/meeting_room/availability' => 'api/v1/meetings#availability_check'
  get '/api/v1/invitee/availability' => 'api/v1/invitations#user_availability_check'

  namespace :api do
    namespace :v1 do
      # GET all users
      resources :users, only: :index

      # GET all meeting rooms
      resources :meeting_rooms, only: :index

      # Meetings & Invitations API
      resources :meetings do
        resources :invitations do
        end
      end

      #Meetings & Comments APi
      resources :meetings do
        resources :comments
      end
    end
  end

  # -----------
  # Admin APIs
  # -----------

  # GET all users
  namespace :api do
    namespace :v1 do

      resources :venues do
        resources :meeting_rooms
      end

    end
  end



end
