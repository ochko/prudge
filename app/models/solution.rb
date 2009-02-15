class Solution < ActiveRecord::Base
  belongs_to :problem
  belongs_to :user
  belongs_to :language
  has_many :results, :dependent => :destroy

  has_attachment  :storage => :file_system,
                  :path_prefix => 'judge/src',
                  :max_size => 64.kilobytes

  has_many :comments,
           :as => 'topic',
           :class_name => 'Comment',
           :foreign_key => 'topic_id',
           :order => 'created_at',
           :dependent => :destroy

  validates_as_attachment

  def update_results(checked, correct, percent, avg_time)
    class << self
      def record_timestamps; false; end
    end

    self[:checked] = checked
    self[:correct] = correct
    self[:percent] = percent
    self[:avg_time] = avg_time

    save!

    check_best
  end

  def check_best
    class << self
      def record_timestamps; false; end
    end

    others = Solution.
      find(:all,
           :conditions => ['user_id = ? and problem_id = ? and id <> ?',
                           user_id, problem_id, id])
    for twin in others
      if twin.percent > percent ||
          (twin.percent == percent && twin.avg_time < avg_time)
        update_attribute_with_validation_skipping(:isbest, false)
      else
        update_attribute_with_validation_skipping(:isbest, true)
        twin.update_attribute(:isbest, false)
      end
    end
  end

end
