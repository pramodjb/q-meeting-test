require 'rails_helper'

RSpec.describe Api::V1::MeetingsController, type: :request do
  let(:meeting) {FactoryGirl.create(:meeting)}
  let(:invitation) {FactoryGirl.create(:invitation)}
  let!(:user) { FactoryGirl.create(:user)}

  let(:user_request_headers) {
    {
      "Accept" => "application/json",
      "Content-Type" => "application/json",
      "Authorization" => user.auth_token
    }
  }
  describe "index" do
    before(:all) do
      @mysore = FactoryGirl.create(:meeting_room, name: "Mysore")
      @denver = FactoryGirl.create(:meeting_room, name: "Denver")
      @costa_rica = FactoryGirl.create(:meeting_room, name: "Costa Rica")

      @ram = FactoryGirl.create(:user)
      @sita = FactoryGirl.create(:user)
      @lakshman = FactoryGirl.create(:user)
      @hanuman = FactoryGirl.create(:user)

      @ram_request_headers = { "Authorization" => @ram.auth_token, "Accept" => "application/json", "Content-Type" => "application/json"}
      @sita_request_headers = { "Authorization" => @sita.auth_token, "Accept" => "application/json", "Content-Type" => "application/json"}
      @lakshman_request_headers = { "Authorization" => @lakshman.auth_token, "Accept" => "application/json", "Content-Type" => "application/json"}
      @hanuman_request_headers = { "Authorization" => @hanuman.auth_token, "Accept" => "application/json", "Content-Type" => "application/json"}
      
      # Ram Invites Sita & Lakshman for a meeting
      @meeting1 = FactoryGirl.create(:meeting, owner: @ram, meeting_room: @mysore)
      @invitation11 = FactoryGirl.create(:invitation, inviter: @ram, invitee: @sita, meeting: @meeting1)
      @invitation12 = FactoryGirl.create(:invitation, inviter: @ram, invitee: @lakshman, meeting: @meeting1)
      @invitation13 = FactoryGirl.create(:invitation, inviter: @ram, invitee: @ram, meeting: @meeting1)

      # Ram Invites Sita & Lakshman & Hanuman for another meeting
      @meeting2 = FactoryGirl.create(:meeting, owner: @ram, meeting_room: @denver)
      @invitation21 = FactoryGirl.create(:invitation, inviter: @ram, invitee: @sita, meeting: @meeting2)
      @invitation22 = FactoryGirl.create(:invitation, inviter: @ram, invitee: @lakshman, meeting: @meeting2)
      @invitation23 = FactoryGirl.create(:invitation, inviter: @ram, invitee: @hanuman, meeting: @meeting2)
      @invitation23 = FactoryGirl.create(:invitation, inviter: @ram, invitee: @ram, meeting: @meeting2)

      # Sita and Ram has a private chat
      @meeting3 = FactoryGirl.create(:meeting, owner: @sita, meeting_room: @costa_rica)
      @invitation31 = FactoryGirl.create(:invitation, inviter: @sita, invitee: @ram, meeting: @meeting3)
      @invitation32 = FactoryGirl.create(:invitation, inviter: @sita, invitee: @sita, meeting: @meeting3)

      # Lakshman and Ram has a secret meeting
      @meeting4 = FactoryGirl.create(:meeting, owner: @lakshman, meeting_room: @mysore)
      @invitation41 = FactoryGirl.create(:invitation, inviter: @lakshman, invitee: @ram, meeting: @meeting4)
      @invitation42 = FactoryGirl.create(:invitation, inviter: @lakshman, invitee: @lakshman, meeting: @meeting4)
    end
    
    context "Positive case" do
      it "should filter meetings by owner" do
        get "/api/v1/meetings", {owner_id: @ram.id }, @ram_request_headers
        expect(response.status).to eq(200)
        body = JSON.parse(response.body)
        expect(body["data"].size).to eq(2)
        expect(body["data"][0].keys).to eq(["id", "owner_id", "from_datetime", "to_datetime", "from_time", "to_time", "date", "meeting_room_id", "description", "name", "meeting_room"])
        expect(body["data"][0]["id"]).to eq(@meeting1.id)
        expect(body["data"][1]["id"]).to eq(@meeting2.id)

        get "/api/v1/meetings", {owner_id: @sita.id }, @ram_request_headers
        expect(response.status).to eq(200)
        body = JSON.parse(response.body)
        expect(body["data"].size).to eq(1)
        expect(body["data"][0].keys).to eq(["id", "owner_id", "from_datetime", "to_datetime", "from_time", "to_time", "date", "meeting_room_id", "description", "name", "meeting_room"])
        expect(body["data"][0]["id"]).to eq(@meeting3.id)

        get "/api/v1/meetings", {owner_id: @lakshman.id }, @ram_request_headers
        expect(response.status).to eq(200)
        body = JSON.parse(response.body)
        expect(body["data"].size).to eq(1)
        expect(body["data"][0].keys).to eq(["id", "owner_id", "from_datetime", "to_datetime", "from_time", "to_time", "date", "meeting_room_id", "description", "name", "meeting_room"])
        expect(body["data"][0]["id"]).to eq(@meeting4.id)
      end

      it "should filter meetings by meeting room" do
        get "/api/v1/meetings", {meeting_room_id: @mysore.id }, @ram_request_headers
        expect(response.status).to eq(200)
        body = JSON.parse(response.body)
        expect(body["data"].size).to eq(4)
        expect(body["data"][0].keys).to eq(["id", "owner_id", "from_datetime", "to_datetime", "from_time", "to_time", "date", "meeting_room_id", "description", "name", "meeting_room"])
        expect(body["data"].map{|x| x["id"] }).to match_array([@meeting1.id, @meeting2.id, @meeting3.id, @meeting4.id])

        get "/api/v1/meetings", {meeting_room_id: @denver.id }, @ram_request_headers
        expect(response.status).to eq(200)
        body = JSON.parse(response.body)
        expect(body["data"].size).to eq(4)
        expect(body["data"][0].keys).to eq(["id", "owner_id", "from_datetime", "to_datetime", "from_time", "to_time", "date", "meeting_room_id", "description", "name", "meeting_room"])
        expect(body["data"].map{|x| x["id"] }).to match_array([@meeting1.id, @meeting2.id, @meeting3.id, @meeting4.id])

        get "/api/v1/meetings", {meeting_room_id: @costa_rica.id }, @ram_request_headers
        expect(response.status).to eq(200)
        body = JSON.parse(response.body)
        expect(body["data"].size).to eq(4)
        expect(body["data"][0].keys).to eq(["id", "owner_id", "from_datetime", "to_datetime", "from_time", "to_time", "date", "meeting_room_id", "description", "name", "meeting_room"])
        expect(body["data"].map{|x| x["id"] }).to match_array([@meeting1.id, @meeting2.id, @meeting3.id, @meeting4.id])
      end

      it "should filter meetings by invitee" do
        expect(@ram.meetings.filter_by_invitee(@sita)).to match_array([@meeting1, @meeting2, @meeting3])
        expect(@sita.meetings.filter_by_invitee(@ram)).to match_array([@meeting1, @meeting2, @meeting3])
        expect(@hanuman.meetings.filter_by_invitee(@ram)).to match_array([@meeting2])
        get "/api/v1/meetings", {invitee_id: @sita.id }, @ram_request_headers
        expect(response.status).to eq(200)
        body = JSON.parse(response.body)
        expect(body["data"].size).to eq(3)

        expect(body["data"][0].keys).to eq(["id", "owner_id", "from_datetime", "to_datetime", "from_time", "to_time", "date", "meeting_room_id", "description", "name", "meeting_room"])
        expect(body["data"].map{|x| x["id"] }).to match_array([@meeting1.id, @meeting2.id, @meeting3.id])
        
        get "/api/v1/meetings", {invitee_id: @ram.id }, @sita_request_headers
        expect(response.status).to eq(200)
        body = JSON.parse(response.body)
        expect(body["data"].size).to eq(3)
        expect(body["data"][0].keys).to eq(["id", "owner_id", "from_datetime", "to_datetime", "from_time", "to_time", "date", "meeting_room_id", "description", "name", "meeting_room"])
        expect(body["data"].map{|x| x["id"] }).to match_array([@meeting1.id, @meeting2.id, @meeting3.id])

        get "/api/v1/meetings", {invitee_id: @ram.id }, @hanuman_request_headers
        expect(response.status).to eq(200)
        body = JSON.parse(response.body)
        expect(body["data"].size).to eq(1)
        expect(body["data"][0].keys).to eq(["id", "owner_id", "from_datetime", "to_datetime", "from_time", "to_time", "date", "meeting_room_id", "description", "name", "meeting_room"])
        expect(body["data"].map{|x| x["id"] }).to match_array([ @meeting2.id])
      end
    end

    context "Negative case" do
      it "should return error without auth token" do
        get "/api/v1/meetings", {}
        expect(response.code).to eq("401")
      end
    end
  end

  describe "create" do
    context "Positive Case" do
      it "should be able to schedule the meeting for the user" do
        meeting_params = {owner_id: meeting.owner_id, name: "Standup", from_time: "09:15", to_time: "09:40", date: "2016-10-19", meeting_room_id: meeting.meeting_room_id, description: "my text"}
        post "/api/v1/meetings", meeting_params.to_json, user_request_headers
        expect(response.status).to eq(200)
      end
    end
    context "Negative Case" do
      it "should not create meeting without the valid params" do
        meeting_params = {owner_id: meeting.owner_id, name: "Standup", from_time: "9:45", to_time: " ", date: "2015/10/19", meeting_room_id: meeting.meeting_room_id, description: "my text"}

        post "/api/v1/meetings", meeting_params.to_json, user_request_headers
        expect(response.code).to eq("422")

        body = JSON.parse(response.body)
        expect(body['error']['to_time']).to eq(["To time can not be blank", "Invalid To time"])
      end

      it "should not schedule meeting if from_time is after to_time" do
        meeting_params = {owner_id: meeting.owner_id, name: "Standup", from_time: "09:15", to_time: "09:10", date: "2016-10-19", meeting_room_id: meeting.meeting_room_id, description: "my text"}
        post "/api/v1/meetings", meeting_params.to_json, user_request_headers
        expect(response.status).to eq(422)
      end
    end
  end

  describe "Availability" do
    context "Positive Case" do
      it "should be able to show the availablity of the meeting room while scheduling the meeting" do
        meeting_params = {from_time: "09:15", to_time: "09:40", date: "2016-10-23", meeting_room_id: meeting.meeting_room_id}
        get "/api/v1/meeting_room/availability", meeting_params, user_request_headers
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(response_body["availability_status"]).to eq(true)
      end
    end

    context "Negative Case" do
      it "should be able to show the availablity of the meeting room while scheduling the meeting" do
        meeting_params = {from_time: "23:15", to_time: "23:40", date: "2016-10-23", meeting_room_id: meeting.meeting_room_id}
        get "/api/v1/meeting_room/availability", meeting_params, user_request_headers
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(response_body["availability_status"]).to eq(false)
      end
    end
  end

  describe "update" do
    context "Positive case" do
      it "should be able to edit the meeting details" do
        meeting_params = meeting
        meeting_params[:name] = "New Name"
        meeting_params[:from_time] = "10:45"
        meeting_params[:to_time] = "11:45"
        meeting_params[:date] = "2016-11-12"
        meeting_params[:from_datetime] = DateTime.new(2016, 11, 12, 10, 45)
        meeting_params[:to_datetime] = DateTime.new(2016, 11, 12, 11, 45)

        put "/api/v1/meetings/#{meeting.id}", meeting_params.to_json, user_request_headers
        expect(response.status).to eq(200)
      end
    end
  end
end