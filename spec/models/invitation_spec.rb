require 'rails_helper'

RSpec.describe Invitation, type: :model do
  let(:invitation) {FactoryGirl.build(:invitation)}
  context "Factory" do
    it "should validate all the invitation" do
      expect(invitation.valid?).to be true
    end
  end
  
  context "Associations" do
    it {should belong_to :invitee}
    it {should belong_to :inviter}
    it {should belong_to :meeting}
    
  end

  context "Validations" do
    it {should validate_presence_of :invitee_id}
  end

  context "Scopes" do
    it "should check the cavailability of the user for the given date and time" do
      invitee1 = FactoryGirl.create(:user)
      invitee2 = FactoryGirl.create(:user)
      current_user = FactoryGirl.create(:user)

      invitee1_meeting1 = FactoryGirl.create(:meeting, from_time: "10:30", to_time: "10:40", date: "2016-10-23", from_datetime: "Sun, 23 Oct 2016 10:30:00 UTC +00:00", to_datetime: "Sun, 23 Oct 2016 10:40:00 UTC +00:00")
      invitee1_meeting2 = FactoryGirl.create(:meeting, from_time: "11:30", to_time: "12:40", date: "2016-10-23", from_datetime: "Sun, 23 Oct 2016 11:30:00 UTC +00:00", to_datetime: "Sun, 23 Oct 2016 12:40:00 UTC +00:00")
      invitee1_meeting3 = Meeting.new(from_time: "10:30", to_time: "10:40", date: "2016-10-23", from_datetime: "Sun, 23 Oct 2016 10:30:00 UTC +00:00", to_datetime: "Sun, 23 Oct 2016 10:40:00 UTC +00:00")
      invitee1_meeting4 = Meeting.new(from_time: "11:30", to_time: "12:40", date: "2016-10-23", from_datetime: "Sun, 23 Oct 2016 11:30:00 UTC +00:00", to_datetime: "Sun, 23 Oct 2016 12:40:00 UTC +00:00")
      invitee1_meeting5 = Meeting.new(from_time: "09:30", to_time: "12:40", date: "2016-10-23", from_datetime: "Sun, 23 Oct 2016 09:30:00 UTC +00:00", to_datetime: "Sun, 23 Oct 2016 12:40:00 UTC +00:00")
      invitee1_meeting6 = Meeting.new(from_time: "09:30", to_time: "09:45", date: "2016-10-23", from_datetime: "Sun, 23 Oct 2016 09:30:00 UTC +00:00", to_datetime: "Sun, 23 Oct 2016 09:45:00 UTC +00:00")

      invitation1 = FactoryGirl.create(:invitation, meeting_id: invitee1_meeting1.id, invitee_id: invitee1.id, inviter_id: current_user.id)
      invitation2 = FactoryGirl.create(:invitation, meeting_id: invitee1_meeting1.id, invitee_id: invitee2.id, inviter_id: current_user.id)

      expect(Meeting.availability(invitee1_meeting3)).to match_array([invitee1_meeting1])
      expect(Meeting.availability(invitee1_meeting4)).to match_array([invitee1_meeting2])
      expect(Meeting.availability(invitee1_meeting5)).to match_array([invitee1_meeting2, invitee1_meeting1])
      expect(Meeting.availability(invitee1_meeting6)).to match_array([])
      

    end
  end

end
