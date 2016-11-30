module Api
  module V1
    class AuthenticationsController < ApplicationController

      def authenticate
        @user = User.find_by_email(params[:email])

        if @user
          if @user.authenticate(params[:password])
            render :json => {:data => @user, :message => I18n.t("api.authentication_success")}
          else
            render_invalid_json
          end
        else
          render_invalid_json
        end
      end

      private

      def render_invalid_json
        render json: { message: I18n.t("api.authentication_failure"), error: {base: "Invalid email or password"} }, status: 422
      end
    end
  end
end