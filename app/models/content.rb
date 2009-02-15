class Content < ActiveRecord::Base
  belongs_to :lesson
  belongs_to :course
end
