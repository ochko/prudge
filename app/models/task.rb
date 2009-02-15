class Task < ActiveRecord::Base
  belongs_to :subscriber, :class_name=>'User',
             :foreign_key=>'subscriber_id'
  has_many :fulfillments
  has_many :users, :through => 'fulfillments'
  has_many :attachments,
           :as => 'attachable',
           :class_name => 'Attachment',
           :foreign_key => 'attachable_id'
  has_many :comments,
           :as => 'topic',
           :class_name => 'Comment',
           :foreign_key => 'topic_id',
           :dependent => :destroy

  validates_presence_of     :subject, :outline, :price

  acts_as_textiled :outline
  acts_as_textiled :requirements
  acts_as_textiled :deliverables

  acts_as_state_machine :initial => :new, :column => 'status'

  state :new
  state :accepting
  state :paying
  state :closed

  event :commited do
    transitions :from => :new, :to => :accepting
  end

  event :paid do
    transitions :from => :accepting, :to => :paying
  end

  event :finished do
    transitions :from => :new, :to => :closed
    transitions :from => :accepting, :to => :closed
    transitions :from => :paying, :to => :closed
  end

  def has_permission?(user)
    return false if user == :false or user.nil?
    if !user.
        roles.map{ |role| role.title.downcase}.
        include?('subscriber')
      return false
    end

    if self.current_state == :closed
      return false
    end

    if self.subscriber_id == user.id
      return true
    end

    return false
  end

  def available_to(user)
    if self.current_state == :closed
      return false
    end

    return true
  end

end
