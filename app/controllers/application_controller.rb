class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  private
  def parse_pagination_params(default_per_page)
    @per_page = params[:per_page] || default_per_page
    @per_page = default_per_page unless @per_page.to_i > 0
    @current_page = params[:current_page] || "1"
    @current_page = "1" unless @current_page.to_i > 0
  end

  def require_admin
    if request.headers["Authorization"].present?
      @current_user = User.find_by(:auth_token => request.headers["Authorization"])
      render_unauthorized unless @current_user.has_role?(:admin)
    else
      render_unauthorized
    end
  end

  def require_user
    if request.headers["Authorization"].present?
      @current_user = User.find_by(:auth_token => request.headers["Authorization"])
      render_unauthorized unless @current_user
    else
      render_unauthorized
    end
  end

  def render_unauthorized
    render :json => { :message => I18n.t("api.unauthorized")}, :status => 401
  end
    
end
