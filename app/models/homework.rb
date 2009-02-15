class Homework < ActiveRecord::Base
  belongs_to :lesson
  belongs_to :problem
end
