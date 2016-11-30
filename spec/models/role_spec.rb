require 'rails_helper'

RSpec.describe Role, type: :model do
  let(:user) {FactoryGirl.build(:user)}

	it "should validate the admin role" do
		user.add_role :admin
		expect(user.has_role?(:admin)).to be true
	end

	it "should not validate the admin role" do
		user.add_role :moderator
		expect(user.has_role?(:admin)).to be false
	end
end
 	 