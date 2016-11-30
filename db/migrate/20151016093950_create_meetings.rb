class CreateMeetings < ActiveRecord::Migration
  def change
    create_table :meetings do |t|
      t.integer :owner_id
      t.datetime :from_datetime
      t.datetime :to_datetime
      t.string :from_time
      t.string :to_time
      t.string :date
      t.integer :meeting_room_id
      t.text :description

      t.timestamps null: false
    end
  end
end
