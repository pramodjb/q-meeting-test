class CreateMeetingRooms < ActiveRecord::Migration
  def change
    create_table :meeting_rooms do |t|
      t.string :name
      t.integer :venue_id
      t.integer :seating_capacity
      t.boolean :ac,:default => false
      t.boolean :wifi, :default => false
      t.boolean :tv,:default => false
      t.boolean :speaker,:default => false
      t.boolean :microphone,:default => false
      t.boolean :projector,:default => false

      t.timestamps null: false
    end
  end
end
