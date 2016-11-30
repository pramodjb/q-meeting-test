class Api::V1::InvitationsController < ApplicationController

  before_action :require_user

  def index
    @meeting = Meeting.find(params[:meeting_id])
    @invitations = @meeting.invitations.all
    render json: { data: @invitations.as_json(:include => {:invitee => {only: :name}})}, :status => 200
  end

  def create
    @meeting = Meeting.find(params[:meeting_id])
    @invitation = @meeting.invitations.new(invitee_params)
    if(@invitation.valid?)
      @invitation.inviter_id = @current_user.id
      @invitation.save
      render json: {data: @invitation, message: I18n.t("invitation.create"), :status => 201}
    else
      render json: {message: I18n.t("invitation.create_failed")}, :status => 422
    end
  end

  def update
    @meeting = Meeting.find(params[:meeting_id])
    @invitee = @meeting.invitations.find_by_invitee_id(@current_user.id)
    @invitee.update_attributes(invitee_params)
    if(@invitee.valid?)
      @invitee.save
      render json: {data: @invitee, message: I18n.t("invitation.update"), :status => 200}
    else
      render json: {message: I18n.t("invitation.update_failed")}, :status => 422
    end
  end

  def destroy
    @invitation = Invitation.find_by_id(params[:id])
    if @invitation
      @invitation.destroy
      render json: {
        data: @invitation,
        message: I18n.t("invitation.destroy"),
        status: 200
      }
    else
      render_422(I18n.t("invitation.destroy_failed", id: params[:id]))
    end
  end

  def user_availability_check
    invitations = Invitation.where("invitee_id = ?", params[:invitee_id])
    invited_meetings = Meeting.joins(:invitations).where("invitee_id = ?", params[:invitee_id])
    @meeting = Meeting.find_by_id(params[:meeting_id])
    relation = invited_meetings.availability(@meeting)
    if (relation.count == 0)
      avail = true;
    else 
      avail = false;
    end
    render json: {data: relation, availability_status: avail}
  end

  private

  def invitee_params
    params.permit(:inviter_id, :invitee_id, :meeting_id, :rsvp_status)
  end

  def render_422(message = "Failed to perform the action.")
    render json: {
      data: @invitation,
      error: @invitation ? @invitation.errors : {},
      message: message, status: 422
    }
  end

end