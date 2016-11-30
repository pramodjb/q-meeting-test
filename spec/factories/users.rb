FactoryGirl.define do
	factory :user do
		sequence(:name) { |n| "User Name #{n}" }	
		sequence(:email) { |n| "email#{n}@domain.com" }	
		password User::DEFAULT_PASSWORD
	end

	factory :admin_user, :parent => :user do
		after(:create) do |user|
			# .add_role is the method that the RolesManager use to change roles.
			user.add_role(:admin)
		end
	end
end