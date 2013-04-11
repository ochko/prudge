ThinkingSphinx::Index.define :page, :with => :active_record do
  indexes :title
  indexes :content
  
  set_property :field_weights => { 
    :title => 11,
    :content => 8
  }

  set_property :delta => true
end
