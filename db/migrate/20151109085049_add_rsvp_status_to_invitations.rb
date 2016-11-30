class AddRsvpStatusToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :rsvp_status, :string
  end
end
