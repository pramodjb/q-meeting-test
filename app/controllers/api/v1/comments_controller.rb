module Api
  module V1
    class CommentsController < ApplicationController
      before_action :require_user
      

      def index
        @meeting = Meeting.find(params[:meeting_id])
        @comments= @meeting.comments.all
        render json: {data:@comments}
      end

      def create
        @meeting = Meeting.find(params[:meeting_id])
        @comment = @meeting.comments.new(comment_params)
        @comment.commenter = @current_user.name
        if @comment.valid?
          @comment.save
          render json: {data: @comment, message: "comment add to meeting", :status => 201}
        else
          render json: {message: "comment fail to add to meeting", error:@comment.errors}, :status => 422
        end
      end

      def destroy
        @comment = Comment.find_by_id(params[:id])
        if (@comment.commenter == @current_user.name)
          @comment.destroy
          render json: {data: @comment, message: "comment was removed successfully", :status => 200}
        else
          render json: {data: @comment, message: "Not able to delete this comment", :status => 422}
        end
      end

      def comment_params
        params.permit(:meeting_id, :comments, :commenter)
      end
    end
  end
end