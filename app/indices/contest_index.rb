ThinkingSphinx::Index.define :contest, :with => :active_record, :delta => true do
  indexes :name
  indexes :description
  
  set_property :field_weights => { 
    :name => 9,
    :description => 5
  }
end
