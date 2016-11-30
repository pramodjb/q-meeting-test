require 'rails_helper'
RSpec.describe Api::V1::CommentsController, type: :request do
  let(:meeting) {FactoryGirl.create(:meeting)}
  let(:comment) {FactoryGirl.create(:comment)}
  let(:current_user) {FactoryGirl.create(:user)}
  let(:user_request_headers) {
    {
      "Accept" => "application/json",
      "Content-Type" => "application/json",
      "Authorization" => current_user.auth_token
    }
  }

  context "Index" do
    it "should list all comments" do
      meeting1 = FactoryGirl.create(:meeting)
      meeting2 = FactoryGirl.create(:meeting)

      comment1 = FactoryGirl.create(:comment, meeting_id:meeting1.id, comments:"comment_1")
      comment2 = FactoryGirl.create(:comment, meeting_id:meeting2.id, comments:"comment_2")
      comment3 = FactoryGirl.create(:comment, meeting_id:meeting1.id, comments:"comment_3")
      get    "/api/v1/meetings/#{meeting1.id}/comments", {}, user_request_headers
      expect(response.status).to eq(200)
      body = JSON.parse(response.body)
      expect(body["data"].size).to eq(2)
      expect(body['data'].first["comments"]).to eq("comment_1")
      expect(body['data'][1]["comments"]).to eq("comment_3")
      expect(body["data"].first.keys).to eq(["id", "comments", "created_at", "updated_at", "meeting_id", "commenter"])
    end
  end

  context "post request" do
    context "positive case" do
      it "should add comments to meeting" do
        meeting = FactoryGirl.create(:meeting)
        comments_params = {meeting_id: meeting.id, comments: "pramod" ,commenter: "commenter"}
        post  "/api/v1/meetings/#{meeting.id}/comments", comments_params.to_json, user_request_headers
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(response_body.keys).to eq(["data", "message", "status"])
        data = response_body["data"]
        expect(data["meeting_id"]).to eq(comments_params[:meeting_id])
        expect(data["comments"]).to eq(comments_params[:comments])
        expect(response_body["message"]).to eq("comment add to meeting")
      end
    end

    context "negative cases" do
      it "should not be able to add comment without auth_token" do
        meeting = FactoryGirl.create(:meeting)
        comments_params = {meeting_id: meeting.id, comments: "pramod"}
        post  "/api/v1/meetings/#{meeting.id}/comments", comments_params.to_json
        expect(response.status).to eq(401)
      end

      it "should not be able to add comment if blank" do
        meeting = FactoryGirl.create(:meeting)
        comments_params = {meeting_id: meeting.id, comments: ""}
        post  "/api/v1/meetings/#{meeting.id}/comments", comments_params.to_json, user_request_headers
        expect(response.status).to eq(422)
        body = JSON.parse(response.body)
        expect(body['error']['comments']).to eq(["can't be blank"])
      end
    end
  end

  context "Delete the comment" do
    context "Positive case" do
      it "An user should delete the comment" do
        comment1 = FactoryGirl.create(:comment, commenter: current_user.name)
        delete "/api/v1/meetings/#{comment1.meeting.id}/comments/#{comment1.id}",{}, user_request_headers
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(Comment.count).to eq(0)
        expect(response_body.keys).to eq(["data", "message", "status"])
        data = response_body["data"]
        expect(data["comments"]).to eq(comment.comments)
        message = response_body["message"]
        expect(message).to eq("comment was removed successfully")
      end
    end
  end

  context "negative case" do
    it "should not be able to delete comment " do
      delete "/api/v1/meetings/#{comment.meeting.id}/comments/#{comment.id}",{}, user_request_headers
      expect(response.status).to eq(200)
      response_body = JSON.parse(response.body)
      expect(Comment.count).to eq(1)
      expect(response_body.keys).to eq(["data", "message", "status"])
      data = response_body["data"]
      expect(data["comments"]).to eq(comment.comments)
      message = response_body["message"]
      expect(message).to eq("Not able to delete this comment")

    end
  end

end