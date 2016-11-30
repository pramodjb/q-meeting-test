class Venue < ActiveRecord::Base
  
  # Associations
  has_many :meeting_rooms

  #validations
  validates :name, :presence => true, uniqueness: { case_sensitive: false}
  validates :location, :presence => true

  # Scopes
  scope :search, lambda {|query| where( "LOWER(venues.name) LIKE LOWER('%#{query}%') OR LOWER(venues.location) LIKE LOWER('%#{query}%') ")}
end