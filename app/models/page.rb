class Page < ActiveRecord::Base
  named_scope :news, :conditions=>["category = ?", 'news'], :order => "created_at desc"
  named_scope :help, :conditions=>["category = ?", 'help'], :order => "created_at desc"
  named_scope :rules, :conditions=>["category = ?", 'rule'], :order => "created_at desc"

  define_index do
    indexes :title
    indexes :content
    set_property :field_weights => { 
      :title => 11,
      :content => 8
    }
    set_property :delta => true
  end

  def name
    title
  end

  def text
    content
  end
end
