class QuestionAnswer < ActiveRecord::Base
  acts_as_textiled :answer
  validates_presence_of     :question
end
