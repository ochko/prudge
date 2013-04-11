ThinkingSphinx::Index.define :lesson, :with => :active_record do
  indexes :title
  indexes :text

  set_property :field_weights => { 
    :title => 8,
    :text => 5
  }

  set_property :delta => true
end
