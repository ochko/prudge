class Fulfillment < ActiveRecord::Base
  belongs_to :task
  belongs_to :user
  has_many :attachments,
           :as => 'attachable',
           :class_name => 'Attachment',
           :foreign_key => 'attachable_id'

  acts_as_textiled :outline

  def has_permission?(user)
    return false if user == :false or user.nil?
    if self.task.current_state == :closed
      return false
    end

    if self.user_id == user.id
      return true
    end

    return false
  end

  def available_to(user)
    return false if user == :false or user.nil?
    if self.user_id == user.id
      return true
    end

    if self.task.subscriber_id == user.id
      return true
    end

    return false
  end

end
