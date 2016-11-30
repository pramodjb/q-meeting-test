class Api::V1::VenuesController < ApplicationController
  
  before_action :require_admin, except: :index
  # before_action :require_user, [only: :index]
  
  NO_OF_VENUES_IN_A_PAGE = 4

  def index
    relation = Venue.where("").order(updated_at: :desc)
    if params[:query]
      query = params[:query].strip
      relation = relation.search(query) if !query.blank?
    end

    parse_pagination_params(NO_OF_VENUES_IN_A_PAGE)
    venues = relation.order("updated_at desc").page(@current_page).per(@per_page)

    render json: {
      data: venues.as_json(:include => :meeting_rooms),
      total_count: venues.total_count,
      per_page: @per_page.to_i,
      current_page: @current_page.to_i
    }
  end

  def create
    @venue = Venue.new(venue_params)
    if @venue.save
      render json: {
        data: @venue,
        message: I18n.t("venue.create"),
        status: 201
      }
    else
      render_422(I18n.t("venue.create_failed"))
    end
  end

  def update
    @venue = Venue.find_by_id(params[:id])
    if @venue
      @venue.assign_attributes(venue_params)
      if @venue.save
        render json: {
          data: @venue,
          message: I18n.t("venue.update"),
          status: 200
        }
      else
        render_422(I18n.t("venue.update_failed"))
      end
    else
      render_422(I18n.t("venue.update_failed"))
    end
  end

  def destroy
    @venue = Venue.find_by_id(params[:id])
    if @venue
      if @venue.meeting_rooms.blank?
        @venue.destroy
        render json: {
          data: @venue,
          message: I18n.t("venue.destroy"),
          status: 200
        }
      else
        render_422(I18n.t("venue.destroy_failed_meeting_rooms_not_blank", id: params[:id]))
      end
    else
      render_422(I18n.t("venue.destroy_failed", id: params[:id]))
    end
  end

  private

  def venue_params
    params.permit(:name, :location)
  rescue
    {}
  end

  def render_422(message = "Failed to perform the action.")
    render json: {
        data: @venue,
        error: @venue ? @venue.errors : {},
        message: message, status: 422
      }
  end
  
end