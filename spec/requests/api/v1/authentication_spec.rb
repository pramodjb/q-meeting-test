require 'rails_helper'

RSpec.describe Api::V1::AuthenticationsController, :type => :request do
  
  let(:user) {FactoryGirl.create(:user)}
  let!(:admin) {FactoryGirl.create(:admin_user)}
  
  context "authenticate" do
    context "Postive Case" do
      it "should return the user with valid auth token " do
        credentials = {email: user.email, password: user.password}
        post "/api/v1/authenticate", credentials
        expect(response.status).to eq(200)
        body = JSON.parse(response.body)

        expect(body["message"]).to eq("You have successfully authenticated")
      end

      it "should return the user with admin role" do
        credentials = {email: admin.email, password: admin.password}
        post "/api/v1/authenticate", credentials
        expect(response.status).to eq(200)
        body = JSON.parse(response.body)
        expect(body["data"]["user_roles"][0]).to eq("admin")
      end
    end

    context "Negative Case" do
      it "should return error for invalid username" do
        credentials = {email: "invalid email", password: user.password }

        post "/api/v1/authenticate", credentials
        body = JSON.parse(response.body)

        expect(response.status).to eq(422)
        expect(body["message"]).to eq("Authentication Failure")
        expect(body["error"]["base"]).to eq("Invalid email or password")
      end

      it "should return error for invalid password" do
        credentials = {email: user.email, password: "invalid password"}

        post "/api/v1/authenticate", credentials
        body = JSON.parse(response.body)

        expect(response.status).to eq(422)
        expect(body["message"]).to eq("Authentication Failure")
        expect(body["error"]["base"]).to eq("Invalid email or password")
      end
    end
  end
  
end