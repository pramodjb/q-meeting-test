class User < ActiveRecord::Base

  rolify
  has_secure_password

  #Associations
  has_many :invitations, foreign_key: :invitee_id
  has_many :meetings, :through => :invitations

  # Callbacks
  before_save :generate_auth_token

  # Constants
  DEFAULT_PASSWORD = "Password@1"
  EXCLUDED_JSON_ATTRIBUTES = [:password_digest,:created_at,:updated_at]
  INCLUDED_JSON_ATTRIBUTES = []

  # Validations
  validates :name, :presence => true
  validates :email, :presence => true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/, message: "Invalid Email Address" }
  validates :password, :presence => true, format: { with: /(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*\w).{8,16}/, message: "It should contain atleast 1 Capital, 1 Special character, 1 Numeric with 8-16 character length" }

  # Instance Methods
  def as_json(options={})
    exclusion_list = []
    exclusion_list += EXCLUDED_JSON_ATTRIBUTES
    options[:except] ||= exclusion_list

    options[:methods] = [:user_roles]
    super(options)
  end

  # returns a list of roles (Array) if the user has any role. 
  # else return nil
  def user_roles
    self.roles.pluck :name
  end

  def generate_auth_token
    begin
      self.auth_token = SecureRandom.hex
    end while self.class.exists?(auth_token: auth_token)
  end
  
end