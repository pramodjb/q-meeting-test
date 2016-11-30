module Api
  module V1
    class UsersController < ApplicationController

    	before_action :require_user

      def index
        @users = User.without_role(:admin).order(:name).all
        render json: { data: @users }, :status => 200 
      end
      
    end
  end
end