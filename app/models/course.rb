class Course < ActiveRecord::Base
  has_many :groups, :dependent => :destroy
  has_many :contents, :dependent => :destroy
  has_many :lessons, :through => :contents, :order => 'created_at'
  belongs_to :teacher, :class_name => 'User', :foreign_key => 'teacher_id'
end
