require 'rails_helper'

RSpec.describe Api::V1::UsersController, :type => :request do
   let(:user) { FactoryGirl.create(:user) }
   let(:user_request_headers) {
    {
      "Accept" => "application/json",
      "Content-Type" => "application/json",
      "Authorization" => user.auth_token
    }
  }
  
  context "index" do
    it "should list all the users" do
      3.times { FactoryGirl.create(:user) }
      2.times { FactoryGirl.create (:admin_user) }
      
      user = User.order(:name).first
      get "/api/v1/users",{},user_request_headers
      expect(response.status).to eq(200)
      response_body = JSON.parse(response.body)
      expect(response_body["data"].size).to eq(8)
      expect(response_body["data"].first.keys).to eq(["id", "name", "email", "auth_token", "user_roles"])
      expect(response_body["data"].first["id"]).to eq(user.id)
      expect(response_body["data"].first["name"]).to eq(user.name)
      expect(response_body["data"].first["email"]).to eq(user.email)
      expect(response_body["data"].first["auth_token"]).to eq(user.auth_token)
      expect(response_body["data"].first["user_roles"]).to eq(user.user_roles)
    end
  end
end 