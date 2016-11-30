class Comment < ActiveRecord::Base

  #Associations
  belongs_to :meeting
  #validations
  validates :comments, presence: true
  
end
