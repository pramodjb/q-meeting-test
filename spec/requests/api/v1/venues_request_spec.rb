require 'rails_helper'

RSpec.describe Api::V1::VenuesController, type: :request do

  let!(:admin) { FactoryGirl.create(:admin_user) }
  let(:venue) {FactoryGirl.create(:venue)}

  let(:admin_request_headers) {
    {
      "Accept" => "application/json",
      "Content-Type" => "application/json",
      "Authorization" => admin.auth_token
    }
  }

  describe "index" do
    context "Positive Case" do
      it "should list all the venues" do
        3.times { FactoryGirl.create(:venue) }
        venue = Venue.order(updated_at: :desc).first

        get "/api/v1/venues",{}, admin_request_headers

        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(response_body["data"].size).to eq(4)
        expect(response_body["data"].first["id"]).to eq(venue.id)
        expect(response_body["data"].first["name"]).to eq(venue.name)
        expect(response_body["data"].first["location"]).to eq(venue.location)
        expect(response_body["data"].first["meeting_rooms"]).to match_array([])
        
        expect(response_body["data"].first.keys).to match_array([ "id", "name", "location", "meeting_rooms", "created_at", "updated_at"])
        
        expect(response_body['total_count']).to eq(6)
        expect(response_body['per_page']).to eq(4)
        expect(response_body['current_page']).to eq(1)
      end

      it "should search all the string fields" do
        denver = FactoryGirl.create(:venue, name: "denver location")
        dubai = FactoryGirl.create(:venue, name: "dubai location")
        costarica = FactoryGirl.create(:venue, name: "costarica location")
        mysore = FactoryGirl.create(:venue, name: "mysore location")

        get "/api/v1/venues", {query: "denver"}, admin_request_headers
        expect(response.code).to eq("200")
        body = JSON.parse(response.body)
        expect(body['data'].size).to eq(1)
        expect(body['data'][0]["name"]).to eq("denver location")

        get "/api/v1/venues", {query: " dubai"}, admin_request_headers
        expect(response.code).to eq("200")
        body = JSON.parse(response.body)
        expect(body['data'].size).to eq(1)
        expect(body['data'][0]["name"]).to eq("dubai location")

        get "/api/v1/venues", {query: "costarica"}, admin_request_headers
        expect(response.code).to eq("200")
        body = JSON.parse(response.body)
        expect(body['data'].size).to eq(1)
        expect(body['data'][0]["name"]).to eq("costarica location")

        get "/api/v1/venues", {query: "mysore"}, admin_request_headers
        expect(response.code).to eq("200")
        body = JSON.parse(response.body)
        expect(body['data'].size).to eq(1)
        expect(body['data'][0]["name"]).to eq("mysore location")

        get "/api/v1/venues", {query: "location"}, admin_request_headers
        expect(response.code).to eq("200")
        body = JSON.parse(response.body)
        expect(body['data'].size).to eq(4)
      end

      it "should paginate" do
        ["name1","name2","name3","name4","name5","name6","name7","name8","name9","name10","name11"].each do |name|
          FactoryGirl.create(:venue, name:name)
        end
        get "/api/v1/venues", {}, admin_request_headers
        expect(response.code).to eq("200")
        body = JSON.parse(response.body)
        expect(body['data'].size).to eq(4)
        expect(body['per_page']).to eq(4)
        expect(body['current_page']).to eq(1)
        expect(body['total_count']).to eq(14)

        get "/api/v1/venues", {per_page: 5, current_page: 3}, admin_request_headers
        expect(response.code).to eq("200")
        body = JSON.parse(response.body)
        expect(body['data'].size).to eq(4)
        expect(body['per_page']).to eq(5)
        expect(body['current_page']).to eq(3)
        expect(body['total_count']).to eq(14)
      end
    end
  end

  describe "create" do
    context "Positive Case" do
      it "should Create a venue if the user is an admin" do
        venue_params = FactoryGirl.build(:venue).as_json

        post "/api/v1/venues", venue_params.to_json, admin_request_headers
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)

        expect(Venue.count).to eq(4)
        expect(response_body.keys).to eq(["data", "message", "status"])
        expect(response_body["data"]["name"]).to eq(venue_params["name"])
        expect(response_body["data"]["location"]).to eq(venue_params["location"])
        expect(response_body["message"]).to eq("Venue details was saved successfully")
      end
    end

    context "Negative Case" do
      it "should return proper error for invalid input" do
        venue_params = venue.as_json
        venue_params[:name] = ""
        venue_params[:location] = ""
        
        post "/api/v1/venues",  venue_params.to_json, admin_request_headers
        # expect(response.code).to eq("422")

        body = JSON.parse(response.body)
        expect(body['error']['name']).to eq(["can't be blank"])
        expect(body['error']['location']).to eq(["can't be blank"])
      end

      it "should return error without auth token" do
        post "/api/v1/venues", {}
        expect(response.code).to eq("401")
      end
    end
  end

  describe "update" do
    context "Positive Case" do
      it "should update the venue information" do
        venue_params = venue.as_json
        venue_params[:name] = "New Name"
        venue_params[:location] = "New Location"
        
        put "/api/v1/venues/#{venue.id}",  venue_params.to_json, admin_request_headers
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)

        expect(response_body.keys).to eq(["data", "message", "status" ])
        expect(response_body["data"]["name"]).to eq("New Name")
        expect(response_body["data"]["location"]).to eq("New Location")
        expect(response_body["message"]).to eq("Venue details was saved successfully")
      end
    end
    context "Negative Case" do
      it "should return error without auth token" do
        put "/api/v1/venues/#{venue.id}", {}
        expect(response.code).to eq("401")
      end
    end
  end

  describe "destroy" do
    context "Positive cases" do
      it "should delete a venue" do
        delete "/api/v1/venues/#{venue.id}", {}, admin_request_headers
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(Venue.count).to eq(3)
        expect(response_body.keys).to eq(["data", "message", "status"])
        
        expect(response_body["data"]["name"]).to eq(venue.name)
        expect(response_body["data"]["location"]).to eq(venue.location)
        expect(response_body["message"]).to eq("Venue details was removed successfully")
      end

      it "An admin should not delete a venue if it has meeting rooms" do
        meeting_room = FactoryGirl.create(:meeting_room, venue: venue)
        delete "/api/v1/venues/#{venue.id}", {}, admin_request_headers
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(Venue.count).to eq(4)
        expect(response_body.keys).to eq(["data", "error", "message", "status"])
        data = response_body["data"]
        expect(data["location"]).to eq(venue.location)
        message = response_body["message"]
        expect(message).to eq("Venue can't be deleted if the meeting rooms are present")
      end
    end
    context "Negative cases" do
      it "should show proper error message if it fails to find the venue with the id passed" do
        delete "/api/v1/venues/999",{},admin_request_headers
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(response_body.keys).to eq(["data", "error", "message", "status"])

        message = response_body["message"]
        expect(message).to eq("Couldn't find the venue details with id '999'")
      end
      it "should return error without auth token" do
        delete "/api/v1/venues/#{venue.id}", {}
        expect(response.code).to eq("401")
      end
    end
  end

end