class Api::V1::MeetingRoomsController < ApplicationController

  before_action :require_admin, except: :index
  # before_action :require_user, [only: :index]
  before_action :get_room, only: [:update, :destroy]

  def index
    @venue = Venue.find(params[:venue_id])
    @rooms = @venue.meeting_rooms.all
    render json: { data: @rooms }, :status => 200
  end

  def create
    unless room_params.blank?
      @venue = Venue.find_by_id(params[:venue_id])
      @room=@venue.meeting_rooms.new(room_params)
      if @room.valid?
        @room.save
        render json: { data:@room,
         message: I18n.t("meeting_room.create"),
         status:  201}
       else
        render json: {
         message: I18n.t("meeting_room.create_failed"),
         error:@room.errors
         }, :status => 422
       end
     else
      render json: {  message: "Invalid Input" }, :status => 422
    end
  end

  def update
    if @room && room_params.present?
      @room.assign_attributes(room_params)
      if @room.save
        render json: {
          data: @room,
          message: I18n.t("meeting_room.update"),
          status:  200
        }
      else
        render json: {
          data: @room,
          message: I18n.t("meeting_room.blank"),
          status:  422
        }
      end
    else
      render json: {
       data: @room,
       message: I18n.t("meeting_room.update_failed"),
       status:  304
     }
   end
  end

  def destroy
    if @room
      @room.destroy
      render json: {
        data: @room,
        message: I18n.t("meeting_room.destroy"),

      }
    else
     render json: {  message: I18n.t("meeting_room.destroy_failed")}, :status => 404
   end
 end

  private

  def room_params
    params.permit(:name, :venue_id, :seating_capacity, :ac, :wifi, :speaker, :microphone, :tv, :projector)
  rescue
    {}
  end

  def get_room
    @room = MeetingRoom.find_by_id(params[:id])
  rescue
   render json: {  message: I18n.t("meeting_room.destroy_failed"), :status => 404}
  end
end

