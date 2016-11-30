require 'rails_helper'

RSpec.describe Api::V1::InvitationsController, type: :request do

  let(:meeting) {FactoryGirl.create(:meeting)}
  let(:invitation) {FactoryGirl.create(:invitation)}
  let(:current_user) {FactoryGirl.create(:user)}
  let(:invitee_user) {FactoryGirl.create(:user)}
  let(:user_request_headers) {
    {
      "Accept" => "application/json",
      "Content-Type" => "application/json",
      "Authorization" => current_user.auth_token
    }
  }

  context "Get Request" do
    context "Positive case" do
      it "should be able list all the invitees which belongs to particular meeting" do
        # Create 3 invitations
        invitation1 = FactoryGirl.create(:invitation, meeting: meeting)
        invitation2 = FactoryGirl.create(:invitation, meeting: meeting)
        invitation3 = FactoryGirl.create(:invitation, meeting: meeting)
        get "/api/v1/meetings/#{meeting.id}/invitations", {}, user_request_headers
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(response_body["data"].size).to eq(3)
        expect(response_body["data"].first["inviter_id"]).to eq(invitation1.inviter_id)
        expect(response_body["data"].first["invitee_id"]).to eq(invitation1.invitee_id)
        expect(response_body["data"].first["meeting_id"]).to eq(invitation1.meeting_id)

        # FIXME - Check if the invitee details are present apart from the invitation details
        expect(response_body["data"].first.keys).to eq(["id", "inviter_id", "invitee_id", "meeting_id", "created_at", "updated_at","rsvp_status", "invitee"])
      end
    end
  end

  context "Post Request" do
    context "Positive case" do
      it "should be able to invite user for a meeting" do
        invitee_params = {inviter_id: current_user.id, invitee_id: invitee_user.id, meeting_id: meeting.id}
        post "/api/v1/meetings/#{meeting.id}/invitations", invitee_params.to_json, user_request_headers
        expect(response.status).to eq(200)

        response_body = JSON.parse(response.body)
        expect(response_body.keys).to eq(["data", "message", "status"])
        data = response_body["data"]
        expect(data["inviter_id"]).to eq(invitee_params[:inviter_id])
        expect(data["invitee_id"]).to eq(invitee_params[:invitee_id])
        expect(data["meeting_id"]).to eq(invitee_params[:meeting_id])
      end
    end

    context "Negative case" do
      it "should not be able to invite user without auth_token" do
        invitee_params = {inviter_id: current_user.id, invitee_id: invitee_user.id, meeting_id: meeting.id}
        post "/api/v1/meetings/#{meeting.id}/invitations", invitee_params.to_json
        expect(response.status).to eq(401)
      end

      it "should not be able to invite user without a invitee" do
        invitee_params = {inviter_id: current_user.id, invitee_id: ' ', meeting_id: meeting.id}
        post "/api/v1/meetings/#{meeting.id}/invitations", invitee_params.to_json, user_request_headers
        expect(response.status).to eq(422)
      end
    end
  end

  context "update rsvp status" do
    it "should update the rsvp status information" do
      invitation = FactoryGirl.create(:invitation, invitee_id: current_user.id,  meeting: meeting)

      invitee_params = {rsvp_status: "yes"}

      put "/api/v1/meetings/#{meeting.id}/invitations/#{invitation.invitee_id}",invitee_params.to_json,user_request_headers
      expect(response.status).to eq(200)
      response_body = JSON.parse(response.body)
      expect(response_body.keys).to eq(["data", "message", "status" ])
      data = response_body["data"]
      expect(data["rsvp_status"]).to eq(invitee_params[:rsvp_status])
    end
  end

  context "Destroy" do
    context "Positive Case" do
      it "should delete the invitation" do
        delete "/api/v1/meetings/#{meeting.id}/invitations/#{invitation.id}", {}, user_request_headers
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(Invitation.count).to eq(0)
        expect(response_body.keys).to eq(["data", "message", "status"])
        
        expect(response_body["data"]["inviter_id"]).to eq(invitation.inviter_id)
        expect(response_body["data"]["invitee_id"]).to eq(invitation.invitee_id)
        expect(response_body["message"]).to eq("Invitation was removed successfully")
      end
    end

    context "Negative Case" do
      it "should show proper error message if it fails to find the invitation with the id passed" do
        delete "/api/v1/meetings/#{meeting.id}/invitations/9999",{},user_request_headers
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(response_body.keys).to eq(["data", "error", "message", "status"])

        message = response_body["message"]
        expect(message).to eq("Couldn't find the Invitation details with id '9999'")
      end
      it "should return error without auth token" do
        delete "/api/v1/meetings/#{meeting.id}/invitations/#{invitation.id}", {}
        expect(response.code).to eq("401")
      end
    end
  end

  context "Availability" do
    it "should check the availabilty of the user for the given date and time" do
      invitation_params = {invitee_id: invitee_user.id, meeting_id: meeting.id}
        get "/api/v1/invitee/availability", invitation_params, user_request_headers
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(response_body["availability_status"]).to eq(true)
    end
  end

end
