class Page < ActiveRecord::Base
  named_scope :news, :conditions=>["category = ?", 'news'], :order => "created_at desc"
  named_scope :help, :conditions=>["category = ?", 'help'], :order => "created_at desc"
  named_scope :rules, :conditions=>["category = ?", 'rule'], :order => "created_at desc"
end
