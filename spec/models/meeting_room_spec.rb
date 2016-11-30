require 'rails_helper'

RSpec.describe MeetingRoom, type: :model do
  
  context "Factory" do
    it "should validate all the rooms" do
      expect(FactoryGirl.build(:meeting_room).valid?).to be true
    end
  end

  context "Associations" do
    it { should belong_to(:venue) }
    it { should have_many :meetings } 
  end

  context "Validations" do
    it {should validate_presence_of :name}
    it { should allow_value('name').for(:name)}
    it { should_not allow_value('na').for(:name)}
    it { should_not allow_value('n').for(:name)}

    it {should validate_presence_of :seating_capacity}
    it { should allow_value(5).for(:seating_capacity)}
    it { should_not allow_value(0).for(:seating_capacity)}
    it { should_not allow_value(-1).for(:seating_capacity)}
    it { should_not allow_value(113).for(:seating_capacity)}
  end
end
