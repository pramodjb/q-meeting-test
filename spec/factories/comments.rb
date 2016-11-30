FactoryGirl.define do
  factory :comment do
    association :meeting, :factory => :meeting
    commenter "myuser"
    comments "MyText"
  end

end
