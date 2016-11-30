require 'rails_helper'

RSpec.describe Venue, type: :model do
  
  context "Factory" do
    it "should validate the venue factory" do
      expect(FactoryGirl.build(:venue).valid?).to be true
    end
  end

  context "Validations" do
    it {should validate_presence_of :name}
    it {should validate_uniqueness_of :name}
    it {should validate_presence_of :location}
  end

  context "Scope" do
   it "search" do
     denver = FactoryGirl.create(:venue, name: "denver location")
     dubai = FactoryGirl.create(:venue, name: "dubai location")
     costarica = FactoryGirl.create(:venue, name: "costarica location")
     mysore = FactoryGirl.create(:venue, name: "mysore location")
     arr = [denver ,  dubai, costarica, mysore]
     
     expect(Venue.search("Denver")).to match_array([denver])
     expect(Venue.search("Dubai")).to match_array([dubai])
     expect(Venue.search("Costarica")).to match_array([costarica])
     expect(Venue.search("Mysore")).to match_array([mysore])
     expect(Venue.search("location")).to match_array(arr)
   end
 end
end