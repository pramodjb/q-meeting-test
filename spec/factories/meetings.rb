FactoryGirl.define do
	factory :meeting do
		association :owner, :factory => :user
		name "Standup"
		from_datetime "2016-10-23T23:09:00.000Z"
		to_datetime "2016-10-23T23:25:00.000Z"
		from_time "23:09"
		to_time "23:25"
		date "2016-10-23"
		meeting_room
		description "Meeting Description"
	end
end
