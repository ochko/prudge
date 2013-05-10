ThinkingSphinx::Index.define :problem, :with => :active_record, :delta => true do
  indexes :name
  indexes :text
  indexes :source

  set_property :field_weights => { 
    :name => 10,
    :text => 6,
    :source => 3
  }

  where "active_from < now()"
end
