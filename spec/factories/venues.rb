FactoryGirl.define do
	factory :venue  do
    location "2nd Floor"
    sequence(:name) { |n| "Venue Name #{n}" }	
  end
end







