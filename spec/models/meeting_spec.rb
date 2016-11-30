require 'rails_helper'

RSpec.describe Meeting, type: :model do

  context "Factory" do
    it "should validate the meeting factory" do
      expect(FactoryGirl.build(:meeting).valid?).to be true
    end
  end

  context "Associations" do
    it {should belong_to :meeting_room }
    it {should belong_to :owner }
    it {should have_many :invitations}
    it {should have_many(:invitees).through(:invitations)}
    it {should have_many(:comments)}
  end

  context "Validations" do
    it {should validate_presence_of :from_time}

    it { should allow_value('09:30').for(:from_time)}
    it { should_not allow_value('26:30').for(:from_time)}
    it { should_not allow_value('9:61').for(:from_time)}
    it { should_not allow_value('9:15').for(:from_time)}
    it { should_not allow_value('09-15').for(:from_time)}
    it { should_not allow_value('09:15 am').for(:from_time)}


    it {should validate_presence_of :to_time}

    it { should allow_value('09:30').for(:to_time)}
    it { should_not allow_value('26:30').for(:to_time)}
    it { should_not allow_value('9:61').for(:to_time)}
    it { should_not allow_value('9:15').for(:to_time)}
    it { should_not allow_value('09-15').for(:to_time)}
    it { should_not allow_value('09:15 am').for(:to_time)}

    it {should validate_presence_of :date}

    it { should allow_value('2016-11-14').for(:date)}
    it { should_not allow_value('2015/11/12').for(:date)}
    it { should_not allow_value('12/11/2015').for(:date)}
    it { should_not allow_value('12-11-2015').for(:date)}
    it { should_not allow_value('12-11-2015').for(:date)}
    it { should_not allow_value('2014-11-14').for(:date)}


    it {should validate_presence_of :description}
    it {should validate_presence_of :name}
    it {should validate_presence_of :meeting_room_id}

  end

  context "Scopes" do
    context "search" do
      it "search all string fields" do
        mango = FactoryGirl.create(:meeting, name: "Mango Fruit")
        apple = FactoryGirl.create(:meeting, name: "Apple Fruit")
        orange = FactoryGirl.create(:meeting, name: "Orange Fruit")

        arr = [mango, apple, orange]

        expect(Meeting.search("mango")).to match_array([mango])
        expect(Meeting.search("apple")).to match_array([apple])
        expect(Meeting.search("orange")).to match_array([orange])
        expect(Meeting.search("fruit")).to match_array(arr)
      end
    end
    context "filter_by_owner" do
      it "should filter meetings by owner" do
        ram = FactoryGirl.create(:user)
        sita = FactoryGirl.create(:user)
        lakshman = FactoryGirl.create(:user)
        meeting1 = FactoryGirl.create(:meeting, owner: ram)
        meeting2 = FactoryGirl.create(:meeting, owner: sita)
        meeting3 = FactoryGirl.create(:meeting, owner: lakshman)
        meeting4 = FactoryGirl.create(:meeting, owner: ram)

        expect(Meeting.filter_by_owner(ram)).to match_array([meeting1, meeting4])
        expect(Meeting.filter_by_owner(sita)).to match_array([meeting2])
        expect(Meeting.filter_by_owner(lakshman)).to match_array([meeting3])
      end
    end
    context "filter_by_meeting_room" do
      it "should filter meetings by meeting room" do
        mysore = FactoryGirl.create(:meeting_room, name: "Mysore")
        denver = FactoryGirl.create(:meeting_room, name: "Denver")
        costa_rica = FactoryGirl.create(:meeting_room, name: "Costa Rica")

        meeting1 = FactoryGirl.create(:meeting, meeting_room: mysore)
        meeting2 = FactoryGirl.create(:meeting, meeting_room: denver)
        meeting3 = FactoryGirl.create(:meeting, meeting_room: costa_rica)
        meeting4 = FactoryGirl.create(:meeting, meeting_room: mysore)

        expect(Meeting.filter_by_meeting_room(mysore)).to match_array([meeting1, meeting4])
        expect(Meeting.filter_by_meeting_room(denver)).to match_array([meeting2])
        expect(Meeting.filter_by_meeting_room(costa_rica)).to match_array([meeting3])
      end
    end
    context "filter_by_invitee" do
      it "should filter meetings by invitee" do
        ram = FactoryGirl.create(:user)
        sita = FactoryGirl.create(:user)
        lakshman = FactoryGirl.create(:user)
        hanuman = FactoryGirl.create(:user)

        # Ram Invites Sita & Lakshman for a meeting
        meeting1 = FactoryGirl.create(:meeting, owner: ram)
        invitation11 = FactoryGirl.create(:invitation, inviter: ram, invitee: sita, meeting: meeting1)
        invitation12 = FactoryGirl.create(:invitation, inviter: ram, invitee: lakshman, meeting: meeting1)
        invitation13 = FactoryGirl.create(:invitation, inviter: ram, invitee: ram, meeting: meeting1)

        # Ram Invites Sita & Lakshman & Hanuman for another meeting
        meeting2 = FactoryGirl.create(:meeting, owner: ram)
        invitation21 = FactoryGirl.create(:invitation, inviter: ram, invitee: sita, meeting: meeting2)
        invitation22 = FactoryGirl.create(:invitation, inviter: ram, invitee: lakshman, meeting: meeting2)
        invitation23 = FactoryGirl.create(:invitation, inviter: ram, invitee: hanuman, meeting: meeting2)
        invitation23 = FactoryGirl.create(:invitation, inviter: ram, invitee: ram, meeting: meeting2)

        # Sita and Ram has a private chat
        meeting3 = FactoryGirl.create(:meeting, owner: sita)
        invitation31 = FactoryGirl.create(:invitation, inviter: sita, invitee: ram, meeting: meeting3)
        invitation32 = FactoryGirl.create(:invitation, inviter: sita, invitee: sita, meeting: meeting3)

        # Lakshman and Ram has a secret meeting
        meeting4 = FactoryGirl.create(:meeting, owner: lakshman)
        invitation41 = FactoryGirl.create(:invitation, inviter: lakshman, invitee: ram, meeting: meeting4)
        invitation42 = FactoryGirl.create(:invitation, inviter: lakshman, invitee: lakshman, meeting: meeting4)

        expect(Meeting.filter_by_invitee(ram)).to match_array([meeting1, meeting2, meeting3, meeting4])
        expect(Meeting.filter_by_invitee(sita)).to match_array([meeting1, meeting2, meeting3])
        expect(Meeting.filter_by_invitee(lakshman)).to match_array([meeting1, meeting2, meeting4])
        expect(Meeting.filter_by_invitee(hanuman)).to match_array([meeting2])

        expect(ram.meetings.filter_by_invitee(sita)).to match_array([meeting1, meeting2, meeting3])
        expect(sita.meetings.filter_by_invitee(ram)).to match_array([meeting1, meeting2, meeting3])
        expect(hanuman.meetings.filter_by_invitee(ram)).to match_array([meeting2])
      end
    end

    context "availability" do
      it "should check the availability of the meeting room" do

        mysore = FactoryGirl.create(:meeting_room, name: "Mysore")

        meeting1 = FactoryGirl.create(:meeting, meeting_room: mysore, from_time: "09:15", to_time: "09:45")
        meeting2 = FactoryGirl.create(:meeting, meeting_room: mysore, from_time: "10:25", to_time: "10:40")
        meeting3 = Meeting.new(meeting_room: mysore, from_time: "10:30", to_time: "10:40", from_datetime: "Sun, 23 Oct 2016 10:30:00 UTC +00:00", to_datetime: "Sun, 23 Oct 2016 10:40:00 UTC +00:00")
        meeting4 = Meeting.new(meeting_room: mysore, from_time: "09:20", to_time: "11:00", from_datetime: "Sun, 23 Oct 2016 09:20:00 UTC +00:00", to_datetime: "Sun, 23 Oct 2016 11:00:00 UTC +00:00")
        meeting5 = Meeting.new(meeting_room: mysore, from_time: "09:30", to_time: "10:30", from_datetime: "Sun, 23 Oct 2016 09:30:00 UTC +00:00", to_datetime: "Sun, 23 Oct 2016 10:30:00 UTC +00:00")

        expect(Meeting.availability(meeting3)).to match_array([meeting2])
        expect(Meeting.availability(meeting4)).to match_array([meeting1, meeting2])
        expect(Meeting.availability(meeting5)).to match_array([meeting1, meeting2])
      end
    end
  end

  context "Instance Methods" do
    context "as_json" do
      it "should create a hash with the excluded fields" do
        meeting = FactoryGirl.build(:meeting)
        meeting_json = meeting.as_json
        expect(meeting_json.keys).to match_array(["date", "description", "from_datetime", "from_time", "id", "meeting_room_id", "name", "owner_id", "to_datetime", "to_time"])
      end
    end
    context "parse_date_and_time" do
      it "should concatinate from and to time into from and to datetime" do
        meeting = FactoryGirl.build(:meeting)
        year = meeting.date.split("-")[0]
        month = meeting.date.split("-")[1]
        day = meeting.date.split("-")[2]
        from_hours = meeting.from_time.split(":")[0]
        from_minutes = meeting.from_time.split(":")[1]
        from_datetime = DateTime.new(year.to_i, month.to_i, day.to_i, from_hours.to_i, from_minutes.to_i)
        to_hours = meeting.to_time.split(":")[0]
        to_minutes = meeting.to_time.split(":")[1]
        to_datetime = DateTime.new(year.to_i, month.to_i, day.to_i, to_hours.to_i, to_minutes.to_i)
        expect(from_datetime).to eq(meeting[:from_datetime])
        expect(to_datetime).to eq(meeting[:to_datetime])
      end
    end


    context "from_must_be_before_to_time?" do
      it "should return errors if to_time is less than from_time" do
        meeting = FactoryGirl.build(:meeting, to_time: "23:00")
        expect(meeting).not_to be_valid
      end
    end
  end
end
