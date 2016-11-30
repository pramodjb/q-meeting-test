class AddTimestampsToVenue < ActiveRecord::Migration
  def change
    add_timestamps :venues
  end

end
