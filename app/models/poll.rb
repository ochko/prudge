class Poll < ActiveRecord::Base
  has_many :choices, :class_name=>'PollChoice', :foreign_key=>'poll_id',
           :dependent => :destroy, :order=> 'id'
end
