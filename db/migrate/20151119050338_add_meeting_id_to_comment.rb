class AddMeetingIdToComment < ActiveRecord::Migration
  def change
    add_column :comments, :meeting_id, :integer
  end
end
