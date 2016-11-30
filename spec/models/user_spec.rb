require 'rails_helper'

RSpec.describe User, type: :model do

	let!(:user) {FactoryGirl.build(:user)}

	context "Factory" do
    it "should validate the user factory" do
      expect(FactoryGirl.build(:user).valid?).to be true
    end
  end

  context "Associations" do
    it {should have_many(:meetings).through(:invitations)}
    it {should have_many :invitations}
  end

  context "Validations" do
    it {should validate_presence_of :name}

    it { should validate_presence_of :email }
    it { should allow_value('Vijaysraj006@gmail.com').for(:email)}
    it { should_not allow_value('Vijaysraj006').for(:email)}
    it { should_not allow_value('@gmail').for(:email)}
    it { should_not allow_value('.com').for(:email)}
    it { should_not allow_value('@.com').for(:email)}

    it { should validate_presence_of :password }
    it { should allow_value('Vijay@4564').for(:password)}
    it { should_not allow_value('vijay').for(:password)}
    it { should_not allow_value('VIJAY').for(:password)}
    it { should_not allow_value('vijay@4564').for(:password)}
    it { should_not allow_value('@4564').for(:password)}
    it { should_not allow_value("a"*16).for(:password)}
  end

  context "Callbacks" do
    it "generate_auth_token" do
      user = FactoryGirl.build(:user)
      expect(user.auth_token).to be_nil
      user.generate_auth_token
      expect(user.auth_token).to_not be_nil
    end
  end

  context "Instance Methods" do
    context "as_json" do
      it "should create a hash with the excluded fields" do
        user = FactoryGirl.build(:user)
        user_json = user.as_json
        expect(user_json.keys).to match_array(["auth_token", "email", "id", "name", "user_roles"])
      end
    end

    context "user_roles" do
      it "should return a list of roles" do
        user = FactoryGirl.create(:user)
        user.add_role(:a)
        user.add_role(:b)
        expect(user.user_roles).to match_array(["a", "b"])
      end
    end
  end
  
end