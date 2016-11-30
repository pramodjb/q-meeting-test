  class Meeting < ActiveRecord::Base

  # Associations
  belongs_to :meeting_room
  belongs_to :owner, class_name: "User"
  has_many :invitations
  has_many :invitees, :through => :invitations, foreign_key: :invitee_id
  has_many :comments

  # Callbacks
  before_save :parse_date_and_time, on: [:create, :update]

  # Constants
  EXCLUDED_JSON_ATTRIBUTES = [:created_at, :updated_at]

  # Scopes
  scope :search, lambda {|query| where( "LOWER(meetings.name) LIKE LOWER('%#{query}%')")}
  scope :filter_by_owner, lambda {|owner| (owner && owner.id) ? where("owner_id = #{owner.id}") : where(nil)}
  scope :filter_by_meeting_room, lambda {|meeting_room| (meeting_room && meeting_room.id) ? where("meeting_room_id = #{meeting_room.id}") : where(nil)}
  scope :filter_by_invitee, lambda {|invitee| (invitee && invitee.id) ? joins(:invitees).uniq.where("users.id = #{invitee.id}") : where(nil)}
  scope :availability, lambda {|meeting| where("(? between from_datetime and to_datetime) or (? between from_datetime and to_datetime) or (from_datetime between ? and ?)", meeting.from_datetime, meeting.to_datetime, meeting.from_datetime, meeting.to_datetime)}
     
  # Validations
  validates :from_time, presence: true
  validates :from_time, format: { with: /\A(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]\z/, message: "Invalid From time" }
  validates :from_time, timeliness: { on_or_after: Time.now.strftime("%H:%M")}, :if => :from_time_validation?
  validates :to_time, presence: true, format: { with: /\A(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]\z/, message: "Invalid To time" }
  validates :date, presence: true, timeliness: { on_or_after: lambda { Date.current }, type: :date}
  validates :description, presence: true
  validate  :from_must_be_before_to_time
  validates :name, presence: true
  validates :meeting_room_id, presence: true

  # Instance Methods
  def as_json(options={})
    exclusion_list = []
    exclusion_list += EXCLUDED_JSON_ATTRIBUTES
    options[:except] ||= exclusion_list
    options[:methods] = [:from_time, :to_time, :date]
    super(options)
  end

  def parse_date_and_time
    return if date.blank? || from_time.blank? || to_time.blank?
    year = date.split("-")[0]
    month = date.split("-")[1]
    day = date.split("-")[2]
    from_hours = from_time.split(":")[0]
    from_minutes = from_time.split(":")[1]
    self.from_datetime = DateTime.new(year.to_i, month.to_i, day.to_i, from_hours.to_i, from_minutes.to_i)

    to_hours = to_time.split(":")[0]
    to_minutes = to_time.split(":")[1]
    self.to_datetime = DateTime.new(year.to_i, month.to_i, day.to_i, to_hours.to_i, to_minutes.to_i)
  end

  def from_time_validation?
    date == Date.current.to_s
  end

  def from_must_be_before_to_time
    return if from_time.blank? || to_time.blank?
    errors.add(:from_time, "from_time must be before to_time") unless from_time < to_time
  end

end
