ThinkingSphinx::Index.define :problem, :with => :active_record do
  indexes :name
  indexes :text
  indexes :source

  set_property :field_weights => { 
    :name => 10,
    :text => 6,
    :source => 3
  }

  set_property :delta => true
end
