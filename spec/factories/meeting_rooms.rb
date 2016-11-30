FactoryGirl.define do
  factory :meeting_room do
    venue 
    seating_capacity 10
    ac false
    wifi false
    tv false
    speaker false
    microphone false
    projector false
    sequence(:name) { |n| "MR Name #{n}" }
  end
end
