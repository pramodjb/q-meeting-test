class Invitation < ActiveRecord::Base
  #Associations
  belongs_to :meeting
  belongs_to :invitee, class_name: "User"
  belongs_to :inviter, class_name: "User"

  # Validations
  validates :invitee_id, presence: true
  validates_uniqueness_of :invitee_id, scope: :meeting_id

  scope :availability, lambda {|meeting| where("(? between from_datetime and to_datetime) or (? between from_datetime and to_datetime) or (from_datetime between ? and ?)", meeting.from_datetime, meeting.to_datetime, meeting.from_datetime, meeting.to_datetime)}

end
