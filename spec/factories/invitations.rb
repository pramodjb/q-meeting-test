FactoryGirl.define do
  factory :invitation do
    association :inviter, :factory => :user
    association :invitee, :factory => :user
    association :meeting, :factory => :meeting
  end
end