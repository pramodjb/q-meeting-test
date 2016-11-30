require 'rails_helper'

RSpec.describe Comment, type: :model do
  context "Associations" do
    it {should belong_to (:meeting)}
  end

  context "Validations" do
    it {should validate_presence_of :comments}
  end
end
