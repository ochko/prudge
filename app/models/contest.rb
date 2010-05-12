class Contest < ActiveRecord::Base
  LEVEL_NAMES = { 0 => 'Бүгд', 
    1 => 'Сонирхогч', 
    2 => 'Анхан', 
    3 => 'Дунд', 
    4 => 'Дээд' }

  LEVEL_POINTS = { 0 => 0, 
    1 => 50, 
    2 => 100, 
    3 => 150, 
    4 => 250 }

  has_many :problems
  has_many :solutions
  has_many :grouped_solutions, :class_name => 'Solution',
      :select => 'problem_id, count(id) as tried, sum(correct) as solved',
      :group => 'problem_id', :include => :problem
  has_many :users, :through => :solutions,
      :select => "users.login, users.id, sum(solutions.point) as point,avg(solutions.time) as avg",
      :group => 'user_id', :order => "point desc, avg asc"
  has_many :comments,
           :as => 'topic',
           :class_name => 'Comment',
           :foreign_key => 'topic_id',
           :dependent => :destroy
  

  validates_presence_of :name, :start, :end

  validate do |contest|
    contest.errors.add_to_base("Эхлэх дуусах цаг буруу") if 
      contest.start < contest.end
  end

  named_scope :current, :conditions => "end > NOW()", :order => "start ASC"
  named_scope :finished,:conditions => "end < NOW()", :order => "end DESC"

  def standings
    num, point, avg = 0, 0.0, 0.0
    numbers = [] 
    standers = []
    for user in self.users
      if (point != user.point) || (user.avg.to_f - avg.to_f > 0.1)
        point = user.point
        num += 1
      end
      avg = user.avg
      numbers << num
      standers << user
    end
    [numbers, standers]
  end

  def finished?
    self.end < Time.now
  end

  def level_name
    LEVEL_NAMES[level]
  end

end
