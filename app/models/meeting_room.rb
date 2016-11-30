class MeetingRoom < ActiveRecord::Base
  # Associations
  belongs_to :venue
  has_many :meetings

  # Validations
  validates :name, :presence => true
  validates_length_of :name, :minimum => 3
  validates :seating_capacity, :presence => true,:numericality => { :greater_than => 0, :less_than_or_equal_to => 100 }
end
