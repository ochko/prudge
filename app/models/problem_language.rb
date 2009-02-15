class ProblemLanguage < ActiveRecord::Base #This is the Model of the join table
  belongs_to :problem
  belongs_to :language
end
