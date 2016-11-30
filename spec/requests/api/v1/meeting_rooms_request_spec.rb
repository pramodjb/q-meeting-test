require 'rails_helper'

RSpec.describe Api::V1::MeetingRoomsController, type: :request do
  let(:meeting_room) {FactoryGirl.create(:meeting_room, name: "2nd floor")}
  let(:admin) { FactoryGirl.create(:admin_user) }
  let(:admin_request_headers) {
    {
      "Accept" => "application/json",
      "Content-Type" => "application/json",
      "Authorization" => admin.auth_token
    }
  }
  context "Create" do
    context "Positive Case" do
      it "should Create a meeting_rooms if the user is an admin" do
        room_params = FactoryGirl.build(:meeting_room, name: "2nd floor", seating_capacity: 20, ac: true, wifi: true, speaker: false, projector: true, tv: true, microphone: false)
        post "/api/v1/venues/#{meeting_room.venue.id}/meeting_rooms", room_params.to_json, admin_request_headers
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(MeetingRoom.count).to eq(2)
        expect(response_body.keys).to eq(["data", "message", "status"])

        data = response_body["data"]
        expect(data["name"]).to eq(room_params[:name])
        expect(data["seating_capacity"]).to eq(room_params[:seating_capacity])
        expect(data["ac"]).to eq(true)
        expect(data["wifi"]).to eq(true)
        expect(data["speaker"]).to eq(false)
        expect(data["projector"]).to eq(true)
        expect(data["tv"]).to eq(true)
        expect(data["microphone"]).to eq(false)

        message = response_body["message"]
        expect(message).to eq("Meeting Room details was saved successfully")
      end
    end

    context "Negative Case" do
      it "should not create meeting_room" do
        room_params = {name: "", seating_capacity: 20, ac: true, wifi: true, speaker: false, projector: true, tv: true, microphone: false}
        post "/api/v1/venues/#{meeting_room.venue.id}/meeting_rooms",  room_params.to_json, admin_request_headers
        expect(response.code).to eq("422")

        body = JSON.parse(response.body)
        expect(body['error']['name']).to eq(["can't be blank", "is too short (minimum is 3 characters)"])
      end
      it "should not create meeting_room unless name has minimum length of 3 characters" do
        room_params = {name: "du", seating_capacity: 20, ac: true, wifi: true, speaker: false, projector: true, tv: true, microphone: false}
        post "/api/v1/venues/#{meeting_room.venue.id}/meeting_rooms",  room_params.to_json, admin_request_headers
        expect(response.code).to eq("422")

        body = JSON.parse(response.body)
        expect(body['error']['name']).to eq(["is too short (minimum is 3 characters)"])
      end
      it "should return error without auth token" do
        room_params = {name: "name", seating_capacity: 20, ac: true, wifi: true, speaker: false, projector: true, tv: true, microphone: false}
        post "/api/v1/venues/#{meeting_room.venue.id}/meeting_rooms",  room_params
        expect(response.code).to eq("401")
      end
    end
  end

  context "Index" do
    context "Positive cases" do
      it "should list all the rooms" do
        get  "/api/v1/venues/#{meeting_room.venue.id}/meeting_rooms", {}, admin_request_headers
        expect(response.status).to eq(200)
        body = JSON.parse(response.body)
        expect(body['data'][0]['name']).not_to be_nil
        expect(body['data'][0]['seating_capacity']).not_to be_nil
        expect(body['data'][0]['name']).to eq("2nd floor")
        expect(body['data'][0]['ac']).to eq(false)
        expect(body["data"].first.keys).to eq(["id", "name", "venue_id", "seating_capacity", "ac", "wifi", "tv", "speaker", "microphone", "projector", "created_at", "updated_at"])
      end
    end
  end

  context "Edit MeetingRoom" do
    it "should update the meetingRoom information" do
      venue_params = {name: "mysore", seating_capacity: 20, ac: true, wifi: true, speaker: false, projector: true, tv: true, microphone: false }
      put "/api/v1/venues/#{meeting_room.venue.id}/meeting_rooms/#{meeting_room.id}",venue_params.to_json, admin_request_headers
      expect(response.status).to eq(200)
      response_body = JSON.parse(response.body)
      expect(response_body.keys).to eq(["data", "message","status" ])
      data = response_body["data"]
      expect(data["name"]).to eq("mysore")
      expect(data["seating_capacity"]).to eq(20)
      expect(data["ac"]).to eq(true)
      expect(data["wifi"]).to eq(true)
      expect(data["speaker"]).to eq(false)
      expect(data["projector"]).to eq(true)
      expect(data["tv"]).to eq(true)
      expect(data["microphone"]).to eq(false)
      message = response_body["message"]
      expect(message).to eq("Meeting Room details was saved successfully")

    end
  end

  context "Update" do
    context "Positive cases" do
      it "should update the MeetingRoom" do
        room_params = {name: "pramod", seating_capacity: 20, ac: true, wifi: true, speaker: false, projector: true, tv: true, microphone: false}
        put  "/api/v1/venues/#{meeting_room.venue.id}/meeting_rooms/#{meeting_room.id}", room_params.to_json, admin_request_headers
        expect(response.status).to eq(200)
        body = JSON.parse(response.body)
        expect(body.keys).to eq(["data", "message" ,"status"])
        data = body["data"]
        expect(data["name"]).to eq("pramod")
        expect(data["seating_capacity"]).to eq(20)
        expect(data["ac"]).to eq(true)
        expect(data["wifi"]).to eq(true)
        expect(data["speaker"]).to eq(false)
        expect(data["projector"]).to eq(true)
        expect(data["tv"]).to eq(true)
        expect(data["microphone"]).to eq(false)
        message = body["message"]
        expect(message).to eq("Meeting Room details was saved successfully")
      end
    end

    context "Negative Case" do
      it "should return error without auth token" do
        put "/api/v1/venues/#{meeting_room.venue.id}/meeting_rooms/#{meeting_room.id}", {}
        expect(response.code).to eq("401")
      end
    end
  end

  context "Delete" do
    context "Positive cases" do
      it "An admin should delete the meeting room" do
        delete "/api/v1/venues/#{meeting_room.venue.id}/meeting_rooms/#{meeting_room.id}", {}, admin_request_headers
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(MeetingRoom.count).to eq(0)
        expect(response_body.keys).to eq(["data", "message"])
        data = response_body["data"]
        expect(data["name"]).to eq(meeting_room.name)
        expect(data["seating_capacity"]).to eq(meeting_room.seating_capacity)
        message = response_body["message"]
        expect(message).to eq("Meeting Room details was removed successfully")
      end
    end

    context "Negative cases" do
      it "should show proper error message if it fails to find the meeting with the id passed" do
        delete "/api/v1/venues/#{meeting_room.venue.id}/meeting_rooms/999",{},admin_request_headers
        expect(response.status).to eq(404)
        response_body = JSON.parse(response.body)
        expect(response_body.keys).to eq(["message"] )
        message = response_body["message"]
        expect(message).to eq("Couldn't find the Meeting Room details with id '%{id}'")
      end
    end
  end
end