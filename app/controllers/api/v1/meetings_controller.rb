class Api::V1::MeetingsController < ApplicationController

  before_action :require_user

  def index
    relation = @current_user.meetings.where(nil)
    invitee = User.find_by_id(params[:invitee_id])
    owner = User.find_by_id(params[:owner_id])
    meeting_room = User.find_by_id(params[:meeting_room_id])

    relation = relation.filter_by_owner(owner).filter_by_invitee(invitee).filter_by_meeting_room(meeting_room)

    meetings = relation.order("date, from_time desc").all

    render json: {
      data: meetings.as_json(:include => :meeting_room)
    }
  end

  def create
    unless meeting_params.blank?
      @meeting = Meeting.new(meeting_params)
      if @meeting.valid? 
        if availability
          @meeting.owner_id = @current_user.id
          @meeting.save
          @invitation = Invitation.new(inviter_id: @meeting.owner_id, invitee_id: @meeting.owner_id, meeting_id: @meeting.id)
          @invitation.save
          render json: {data: @meeting, message: "Meeting has been successfully scheduled", :status => 200 }
        else
          render json: { message: "Metting room not available"}
        end
      else
        render json: {  message: "Invalid meeting Record Details", error: @meeting.errors }, :status => 422
      end
    else
      render json: {  message: "Invalid Input" }, :status => 422
    end
  end

  def availability_check
    @meeting = Meeting.new(meeting_params)
    if params[:meeting_room_id].present?
      if params["meeting_id"] && params["meeting_id"] != 'undefined'
        @meetings = MeetingRoom.find_by_id(params[:meeting_room_id]).meetings.where("id <> ?", params["meeting_id"])
      else
        @meetings = MeetingRoom.find_by_id(params[:meeting_room_id]).meetings
      end
      if @meeting.from_time.present? && @meeting.to_time.present? && @meeting.date.present?
        availability
        render json: {data: @meetings.as_json(:include =>{ :owner => {only: :name }}), availability_status: availability}
      else
        render json: {data: @meetings, message: "select date and time to check the availability of meeting room", :status => 422 }
      end
    else
      render json: {message: "Kindly select the meeting room to check the availability"}
    end
  end

  def update
    @meeting = Meeting.find_by_id(params[:id])
    @meeting.invitations.delete_all
    if @meeting
      @meeting.assign_attributes(meeting_params)
      if availability
        @meeting.save
        @invitation = Invitation.new(inviter_id: @meeting.owner_id, invitee_id: @meeting.owner_id, meeting_id: @meeting.id)
        @invitation.save
        render json: {
          data: @meeting,
          message: I18n.t("meeting.update"),
          status: 200
        }
      else
        render_422(I18n.t("meeting.update_failed"))
      end
    else
      render_422(I18n.t("meeting.update_failed"))
    end
  end

  private

  def availability
    if params["meeting_id"] && params["meeting_id"] != "undefined"
      meetings = MeetingRoom.find_by_id(params[:meeting_room_id]).meetings.where("id <> ?", params["meeting_id"])
    else
      meetings = MeetingRoom.find_by_id(params[:meeting_room_id]).meetings
    end
    @meeting.parse_date_and_time
    relation = meetings.availability(@meeting)
    if (relation.count == 0)
      avail = true;
    else 
      avail = false;
    end
  end 

  def render_422(message = "Failed to perform the action.")
    render json: {
      data: @meeting,
      message: message, status: 422
    }
  end


  def meeting_params
    params.permit(:owner_id, :name, :from_time, :to_time, :date, :meeting_room_id, :description)
  end
end