class Group < ActiveRecord::Base
  belongs_to :course

  has_many :memberships, :dependent => :destroy

  has_many :members, :class_name => 'User',
           :through => :memberships,
           :conditions => 'status=1'

  has_many :requests, :class_name => 'User',
           :through => :memberships,
           :source => :member,
           :conditions => 'status=0'

  validates_presence_of :name

  def is_open
    isopen ? 'явагдаж байна' : 'дууссан'
  end

end
