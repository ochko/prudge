class RoleUser < ActiveRecord::Base #This is the Model of the join table
  belongs_to :role
  belongs_to :user
end
